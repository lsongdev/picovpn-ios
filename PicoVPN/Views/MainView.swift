//
//  VPNListView.swift
//  PicoVPN
//
//  Created by Lsong on 1/20/25.
//
import SwiftUI

class EditingStateManager: ObservableObject {
    @Published var ruleIndex: Int?
    @Published var inboundIndex: Int?
    @Published var outboundIndex: Int?
    @Published var profileIndex: Int?
    @Published var balancerIndex: Int?
    @Published var onDemandRuleIndex: Int?
    @Published var showingOnDemandRule = false
    @Published var showingWelcome = false
    @Published var showingQRCode = false
    @Published var showingProfile = false
    @Published var showingRuleEditor = false
    @Published var showingInboundEditor = false
    @Published var showingOutboundEditor = false
    @Published var showingBalancerEditor = false
    @Published var showingImport: Bool = false
    @Published var showingExport: Bool = false
    @Published var showingSetting: Bool = false
}

struct MainView: View {
    @ObservedObject private var appManager = PicoAppManager.shared
    @StateObject private var editingState = EditingStateManager()
    
    private var connectionBinding: Binding<Bool> {
        Binding(
            get: { appManager.isConnected },
            set: { newValue in
                if newValue {
                    appManager.start()
                } else {
                    appManager.stop()
                }
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Connection")) {
                    Toggle("Connect", isOn: connectionBinding)
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Text("\(appManager.status)")
                            .foregroundColor(.secondary)
                    }
                    if appManager.selectedProfile?.config.metrics != nil {
                        NavigationLink("Traffic") {
                            MetricsView()
                        }
                    }
                }
                Section(header: HStack {
                    Text("Profiles")
                    Spacer()
                    if appManager.profiles.contains(where: { !$0.url.isEmpty }) {
                        Button(action: {
                            Task {
                                for index in appManager.profiles.indices {
                                    try await appManager.updateSubscription(index)
                                }
                            }
                        }){
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }) {
                    ForEach(appManager.profiles.indices, id: \.self) { index in
                        profileRow(profile: appManager.profiles[index], at: index)
                    }
                    .onDelete { index in
                        appManager.deleteProfile(index)
                    }
                    .onMove { from, to in
                        appManager.profiles.move(fromOffsets: from, toOffset: to)
                    }
                    if appManager.profiles.isEmpty {
                        Text("No profiles found. Click the plus (+) button to create one.")
                            .foregroundColor(.secondary)
                    }
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Image(systemName: "bolt")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .sheet(isPresented: $editingState.showingProfile) {
                if let index = editingState.profileIndex {
                    ProfileView(
                        profile: appManager.profiles[index],
                        onSave: { profile in
                            appManager.updateProfile(profile)
                        }
                    )
                } else {
                    ProfileView(
                        onSave: { profile in
                            appManager.addProfile(profile)
                        }
                    )
                }
            }
            .sheet(isPresented: $editingState.showingSetting) {
                SettingsView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $editingState.showingWelcome) {
                WelcomeView()
                    .interactiveDismissDisabled(true)
            }
            .navigationTitle(appManager.appName)
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    editingState.profileIndex = nil
                    editingState.showingProfile = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color.accentColor)
                }
                Button(action: { editingState.showingSetting = true }) {
                    Image(systemName: "gear")
                        .foregroundColor(Color.accentColor)
                }
            })
            .onAppear {
                editingState.showingWelcome = !DatasetsManager.shared.validateRequiredDatasets()
                if appManager.autoDeleteLogs {
                    LogManager.cleanupOldLogs(olderThanDays: appManager.deleteLogAfterDays)
                }
            }
        }
        .tint(appManager.appTintColor.getColor())
        .fontDesign(appManager.appFontDesign.getFontDesign())
        .fontWidth(appManager.appFontWidth.getFontWidth())
        .environment(\.dynamicTypeSize, appManager.appFontSize.getFontSize())
        .preferredColorScheme(appManager.colorSchemeMode.getColorScheme())
    }
    func profileRow(profile: Profile, at index: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(profile.name)
                    .font(.headline)
                Text("\(profile.config.routing.rules.count) rules, \(profile.config.outbounds.count) proxies")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if appManager.selectedProfile?.id == profile.id {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.accentColor)
            }
        }
        .onTapGesture {
            appManager.selectProfile(profile)
        }
        .contextMenu{
            if !profile.url.isEmpty {
                Button {
                    Task {
                        try await appManager.updateSubscription(index)
                    }
                } label: {
                    Label("Update Subscription", systemImage: "arrow.clockwise")
                }
            }
            Button {
                UIPasteboard.general.string = try? profile.config.toJSONString()
            } label: {
                Label("Copy JSON", systemImage: "document.on.document")
            }
            Button {
                editingState.profileIndex = index
                editingState.showingProfile = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                appManager.deleteProfile(profile)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
