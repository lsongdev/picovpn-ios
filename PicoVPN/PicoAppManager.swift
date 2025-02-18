//
//  PicoVPNManager.swift
//  PicoVPN
//
//  Created by Lsong on 1/20/25.
//
import SwiftUI
import NetworkExtension

class PicoAppManager: ObservableObject {
    static var shared = PicoAppManager()
    
    private var providerManagerObserver: NSObjectProtocol?
    private let defaults = UserDefaults(suiteName: Common.groupName)!
    
    @AppStorage("colorScheme") var colorSchemeMode: ColorSchemeMode = .system
    @AppStorage("appTintColor") var appTintColor: AppTintColor = .red
    @AppStorage("appFontDesign") var appFontDesign: AppFontDesign = .standard
    @AppStorage("appFontSize") var appFontSize: AppFontSize = .xlarge
    @AppStorage("appFontWidth") var appFontWidth: AppFontWidth = .expanded
    @AppStorage("autoDeleteLogs") var autoDeleteLogs: Bool = true
    @AppStorage("deleteLogAfterDays") var deleteLogAfterDays: Int = 7
    
    
    @Published var tunnelManager = NETunnelProviderManager()
    @Published var tunnelProvider: NEVPNProtocol = NETunnelProviderProtocol()
    
    @Published var isConnected = false
    @Published var status = "Ready"
    @Published var selectedProfile: Profile?
    @Published var profiles: [Profile] = []

    
    init() {
        setupObservers()
        loadProfiles()
        loadVPNConfiguration()
    }
    
    deinit {
        if let observer = providerManagerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupObservers() {
        providerManagerObserver = NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let connection = notification.object as? NEVPNConnection else { return }
            self?.handleVPNStatusChange(connection.status)
        }
    }
    
    private func handleVPNStatusChange(_ status: NEVPNStatus) {
        DispatchQueue.main.async { [weak self] in
            switch status {
            case .connected:
                self?.isConnected = true
                self?.status = "Connected to \(self?.selectedProfile?.name ?? "VPN")"
            case .disconnected:
                 self?.isConnected = false
                self?.status = "Disconnected"
            case .connecting:
                self?.status = "Connecting..."
            case .disconnecting:
                self?.status = "Disconnecting..."
            case .invalid:
                self?.status = "Invalid Configuration"
            case .reasserting:
                self?.status = "Reconnecting..."
            @unknown default:
                self?.status = "Unknown Status"
            }
        }
    }
    
    private func loadVPNConfiguration() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            if let error = error {
                self?.status = "error: \(error.localizedDescription)"
                return
            }
            if let manager = managers?.first {
                self?.tunnelManager = manager
                if let config = manager.protocolConfiguration {
                    self?.tunnelProvider = config
                }
            }
        }
    }
    
    func setupVPNConfiguration() throws {
        tunnelProvider.serverAddress = "picovpn"
        tunnelManager.isEnabled = true
        tunnelManager.localizedDescription = "PicoVPN"
        tunnelManager.protocolConfiguration = tunnelProvider
        tunnelManager.saveToPreferences { [weak self] error in
            if let error = error {
                self?.status = "error: \(error.localizedDescription)"
                return
            } else {
                self?.tunnelManager.loadFromPreferences { _ in }
            }
        }
    }
    
    func start() {
        guard let selectedProfile = selectedProfile else {
            status = "No profile selected"
            return
        }
        if !DatasetsManager.shared.validateRequiredDatasets() {
            status = "Missing required datasets"
            return
        }
        if selectedProfile.config.log != nil {
            LogManager.archiveLogs()
        }
        do {
            try setupVPNConfiguration()
            selectedProfile.config.writeConfig()
            guard let entry = selectedProfile.config.findSocksProxy() else {
                status = "Invalid proxy configuration"
                return
            }
            defaults.set(entry.port, forKey: "port")
            status = "Connecting..."
            try tunnelManager.connection.startVPNTunnel()
        } catch {
            status = "Connection failed: \(error.localizedDescription)"
        }
    }
    
    func stop() {
        status = "Disconnecting..."
        tunnelManager.connection.stopVPNTunnel()
    }

    func restart() {
        if isConnected {
            stop()
            sleep(1)
            start()
        }
    }
    
    private func loadProfiles() {
        guard let data = UserDefaults.standard.data(forKey: "profiles") else {
            print("No data found in UserDefaults")
            return
        }
        
        print("Raw data length:", data.count)
        
        do {
            let decodedProfiles = try JSONDecoder().decode([Profile].self, from: data)
            print("Successfully decoded \(decodedProfiles.count) profiles")
            profiles = decodedProfiles
            selectedProfile = profiles.first
        } catch {
            print("Decoding error:", error)
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found:", context.debugDescription)
                case .typeMismatch(let type, let context):
                    print("Type '\(type)' mismatch:", context.debugDescription)
                case .valueNotFound(let type, let context):
                    print("Value of type '\(type)' not found:", context.debugDescription)
                default:
                    print("Other decoding error:", decodingError)
                }
            }
        }
    }
    
    func saveProfiles() {
        // print("profiles", profiles)
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: "profiles")
        }
    }
    
    func addProfile(_ profile: Profile) {
        profiles.append(profile)
        saveProfiles()
    }
    
    func updateProfile(_ profile: Profile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            if selectedProfile?.id == profile.id {
                selectedProfile = profile
                if isConnected {
                    restart()
                }
            }
            saveProfiles()
        }
    }
    
    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        if selectedProfile?.id == profile.id {
            selectedProfile = nil
            stop()
        }
        saveProfiles()
    }
    
    func deleteProfile(_ atOffsets: IndexSet) {
        atOffsets.forEach { index in
            deleteProfile(profiles[index])
        }
    }
    
    func selectProfile(_ profile: Profile) {
        if selectedProfile?.id == profile.id {
            return
        }
        selectedProfile = profile
        if isConnected {
            restart()
        }
    }
    func updateSubscription(_ index: Int) async throws {
        let proxies = try await profiles[index].fetchProxies()
        let proxyNames = proxies.map { $0.tag }
        await MainActor.run {
            profiles[index].config.outbounds.removeAll(where: {
                profiles[index].subscription_proxy_names.contains($0.tag)
            })
            profiles[index].subscription_proxy_names = proxyNames
            profiles[index].config.outbounds.append(contentsOf: proxies)
            saveProfiles()
        }
    }
}

extension PicoAppManager {
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "PicoVPN"
    }
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }
}

extension PicoAppManager {
    var currentConnectionDuration: TimeInterval {
        return Date().timeIntervalSince(tunnelManager.connection.connectedDate ?? Date())
    }
    var formattedDuration: String {
        let hours = Int(currentConnectionDuration) / 3600
        let minutes = Int(currentConnectionDuration) / 60 % 60
        let seconds = Int(currentConnectionDuration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
