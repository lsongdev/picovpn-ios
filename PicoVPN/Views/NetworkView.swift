//
//  VPNRule.swift
//  PicoVPN
//
//  Created by Lsong on 2/20/25.
//
import SwiftUI
import NetworkExtension

struct NetworkSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var appManager = PicoAppManager.shared
    @StateObject private var editingState = EditingStateManager()
    
    @State private var rules: [NEOnDemandRule] = []
    
    var body: some View {
        List {
            Toggle("Enable OnDemand", isOn: $appManager.tunnelManager.isOnDemandEnabled)
            Section(header: HStack {
                Text("OnDemand Rules")
                Spacer()
                Button {
                    editingState.onDemandRuleIndex = nil
                    editingState.showingOnDemandRule = true
                } label: {
                    Image(systemName: "plus")
                }
            }) {
                ForEach(rules.indices, id: \.self) { index in
                    ruleRow(rule: rules[index], index: index)
                }
                .onMove { from, to in
                    rules.move(fromOffsets: from, toOffset: to)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        rules.remove(at: index)
                    }
                }
            }
            
            
            Section(footer: Text("If YES, the VPN connection will be disconnected when the device goes to sleep. The default is NO.")) {
                Toggle("Disconnect On Sleep", isOn: $appManager.tunnelProvider.disconnectOnSleep)
            }
            
            Section(footer: Text("If YES, route rules for this tunnel will take precendence over any locally-defined routes. The default is NO.")) {
                Toggle("Enforce Routes", isOn: $appManager.tunnelProvider.enforceRoutes)
            }
            
            Section(footer: Text("If YES, all network traffic is routed through the tunnel, with some exclusions.")) {
                Toggle("Include All Networks", isOn: $appManager.tunnelProvider.includeAllNetworks)
            }
            
            if appManager.tunnelProvider.includeAllNetworks {
                
                Section(footer: Text("If YES, all traffic destined for local networks will be excluded from the tunnel. The default is NO on macOS and YES on iOS.")) {
                    Toggle("Exclude Local Networks", isOn: $appManager.tunnelProvider.excludeLocalNetworks)
                }
                
                Section(footer: Text("If YES, The internet-routable network traffic for cellular services (VoLTE, Wi-Fi Calling, IMS, MMS, Visual Voicemail, etc.) is excluded from the tunnel.")) {
                    Toggle("Exclude Cellular Services", isOn: $appManager.tunnelProvider.excludeCellularServices)
                }
                
                Section(footer: Text("If includeAllNetworks is set to YES and this property is set to YES, then network traffic for the Apple Push Notification service (APNs) is excluded from the tunnel. The default value of this property is YES.")) {
                    Toggle("Exclude APNs", isOn: $appManager.tunnelProvider.excludeAPNs)
                }
                
                if #available(iOS 17.4, *) {
                    Section(footer: Text("If includeAllNetworks is set to YES and this property is set to YES, then network traffic used for communicating with devices connected via USB or Wi-Fi is excluded from the tunnel. For example, Xcode uses a network tunnel to communicate with connected development devices like iPhone, iPad and TV. The default value of this property is YES.")) {
                        Toggle("Exclude Device Communication", isOn: Binding(
                            get: {
                                if let tunnelProtocol = self.appManager.tunnelProvider as? NETunnelProviderProtocol {
                                    return tunnelProtocol.excludeDeviceCommunication
                                }
                                return true
                            },
                            set: { newValue in
                                if let tunnelProtocol = self.appManager.tunnelProvider as? NETunnelProviderProtocol {
                                    let mutableProtocol = tunnelProtocol.copy() as! NETunnelProviderProtocol
                                    mutableProtocol.excludeDeviceCommunication = newValue
                                    self.appManager.tunnelProvider = mutableProtocol
                                }
                            }
                        ))
                    }
                }
            }
        
            
            Link(destination: URL(string: "https://developer.apple.com/documentation/networkextension/nevpnprotocol")!) {
                HStack {
                    Text("Documentation")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationBarTitle("Network", displayMode: .inline)
        .navigationBarItems(trailing: saveButton)
        .sheet(isPresented: $editingState.showingOnDemandRule) {
            if let index = editingState.onDemandRuleIndex {
                AddRuleView(rule: OnDemandRule.fromNERule(rules[index])) { rule in
                    rules[index] = rule
                }
            } else {
                AddRuleView() { rule in
                    rules.append(rule)
                }
            }
        }
        .onAppear {
            rules = appManager.tunnelManager.onDemandRules ?? []
        }
    }
    var saveButton: some View {
        Button("Save") {
            appManager.tunnelManager.onDemandRules = rules
            try? appManager.setupVPNConfiguration()
            dismiss()
        }
    }
    func ruleRow(rule: NEOnDemandRule, index: Int) -> some View {
        let action: String
        switch rule.action {
        case .connect:
            action = "Connect"
        case .disconnect:
            action = "Disconnect"
        case .ignore:
            action = "Ignore"
        case .evaluateConnection:
            action = "Evaluate"
        default:
            action = "Unknown"
        }
        let network: String
        switch rule.interfaceTypeMatch {
            case .any:
            network = "Any"
        case .cellular:
            network = "Cellular"
        case .wiFi:
            network = "Wi-Fi"
        case .ethernet:
            network = "Ethernet"
        @unknown default:
            network = "Unknown"
        }
        return HStack {
            VStack(alignment: .leading) {
                Text(action)
                Text(network)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "pencil.circle")
                .foregroundColor(.accentColor)
        }
        .onTapGesture {
            editingState.onDemandRuleIndex = index
            editingState.showingOnDemandRule = true
        }
    }
}

// RuleEditView.swift
struct AddRuleView: View {
    @Environment(\.dismiss) private var dismiss
    @State var rule: OnDemandRule = OnDemandRule()
    let onSave: (NEOnDemandRule) -> Void
    
    @State private var newSSID: String = ""
    @State private var newDomain: String = ""
    @State private var newAddress: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("Action", selection: $rule.action) {
                        ForEach(OnDemandRule.RuleAction.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                }
                
                Section {
                    Picker("Network", selection: $rule.network) {
                        ForEach(OnDemandRule.InterfaceType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                }
                
                Section("SSID") {
                    ForEach(rule.ssids, id: \.self) { ssid in
                        Text(ssid)
                    }
                    HStack {
                        TextField("SSID", text: $newSSID)
                        Spacer()
                        Button {
                            if newSSID.isEmpty { return }
                            rule.ssids.append(newSSID)
                            newSSID = ""
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(newSSID.isEmpty)
                    }
                }
                
                Section("DNS Search Domain Match") {
                    ForEach(rule.domains, id: \.self) { domain in
                        Text(domain)
                    }
                    HStack {
                        TextField("Domain", text: $newDomain)
                        Spacer()
                        Button {
                            if newDomain.isEmpty { return }
                            rule.domains.append(newDomain)
                            newDomain = ""
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(newDomain.isEmpty)
                    }
                }
                
                Section("DNS Server Address Match") {
                    ForEach(rule.address, id: \.self) { addr in
                        Text(addr)
                    }
                    HStack {
                        TextField("Address", text: $newAddress)
                        Spacer()
                        Button {
                            if newAddress.isEmpty { return }
                            rule.address.append(newAddress)
                            newAddress = ""
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(newAddress.isEmpty)
                    }
                }
                
                Section("Probe URL") {
                    TextField("https://", text: $rule.probeURL)
                }
                
            }
            .navigationBarTitle("New Rule", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(rule.toNERule())
                        dismiss()
                    }
                    // .disabled(rule.name.isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
