//
//  ProfileView.swift
//  PicoVPN
//
//  Created by Lsong on 1/20/25.
//
import SwiftUI
import SwiftUIX
import CoreImage.CIFilterBuiltins

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var appManager = PicoAppManager.shared
    @StateObject private var editingState = EditingStateManager()
    @State var profile: Profile = Profile()
    
    var onSave: ((Profile) -> Void)?
    
    private var enableMetrics: Binding<Bool> {
        Binding(
            get: { profile.config.metrics != nil },
            set: { newValue in
                if newValue {
                    profile.config.enableMetrics()
                } else {
                    profile.config.disableMetrics()
                }
            }
        )
    }
    
    private var enableLog: Binding<Bool> {
        Binding(
            get: { profile.config.log != nil },
            set: { newValue in
                if newValue {
                    profile.config.log = Log()
                } else {
                    profile.config.log = nil
                }
            }
        )
    }
    
    private var loglevel: Binding<String> {
        Binding(
            get: { profile.config.log?.loglevel ?? "" },
            set: { newValue in
                profile.config.log?.loglevel = newValue
            }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                InputField("Name", text: $profile.name, placeholder: "profile name")
                
                
                Section(header: Text("DNS")) {
                    NavigationLink(destination: DNSView(
                        dns: profile.config.dns,
                        onSave: { dns in
                            profile.config.dns = dns
                        }
                    )) {
                        VStack(alignment: .leading) {
                            Text("DNS")
                            Text((profile.config.dns != nil) ? "\(profile.config.dns!.tag), \(profile.config.dns!.servers.count) servers" : "<unset>")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contextMenu{
                        Button("Clear Settings", role: .destructive){
                            profile.config.dns = nil
                        }
                    }
                }
                
                Section(header: Text("Policy")) {
                    NavigationLink(destination: PolicyView(
                        policy: profile.config.policy,
                        onSave: { policy in
                            profile.config.policy = policy
                        }
                    )) {
                        Text("Policy")
                    }
                    .contextMenu {
                        Button("Clear Settings", role: .destructive){
                            profile.config.policy = nil
                        }
                    }
                }

                Section(header: Text("Log")) {
                    Toggle("Enable Log", isOn: enableLog)
                    if profile.config.log != nil {
                        Picker("Log Level", selection: loglevel) {
                            Text("debug").tag("debug")
                            Text("info").tag("info")
                            Text("warning").tag("warning")
                            Text("error").tag("error")
                        }
                    }
                    NavigationLink(destination: LogView()) {
                        Text("Logs")
                    }
                }
                
                Section(
                    header: Text("Metrics"),
                    footer: Text("enable metrics will add `metrics-api` `metrics-rule` and other to config, disable will remove them.")
                ) {
                    Toggle("Enable Meteris", isOn: enableMetrics)
                }
                
                
                Section(header: HStack {
                    Text("Inbounds")
                    Spacer()
                    Button(action: {
                        editingState.inboundIndex = nil
                        editingState.showingInboundEditor = true
                    }) {
                        Image(systemName: "plus")
                    }
                }) {
                    ForEach(profile.config.inbounds.indices, id: \.self) { index in
                        inboundRow(for: profile.config.inbounds[index], at: index)
                    }
                    .onMove { from, to in
                        profile.config.inbounds.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { index in
                        profile.config.inbounds.remove(atOffsets: index)
                    }
                }
            
                Section(header: HStack {
                    Text("Outbounds")
                    Spacer()
                    Button(action: {
                        editingState.outboundIndex = nil
                        editingState.showingOutboundEditor = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ) {
                    ForEach(profile.config.outbounds.indices, id: \.self) { index in
                        outboundRow(for: profile.config.outbounds[index], at: index)
                    }
                    .onDelete { index in
                        profile.config.outbounds.remove(atOffsets: index)
                    }
                    .onMove { from, to in
                        profile.config.outbounds.move(fromOffsets: from, toOffset: to)
                    }
                    
                }
                
                
                Section (header: Text("Routing")) {
                    Picker("Domain Strategy", selection: $profile.config.routing.domainStrategy) {
                        Text("AsIs").tag("AsIs")
                        Text("IPIfNonMatch").tag("IPIfNonMatch")
                        Text("IPOnDemand").tag("IPOnDemand")
                    }
                    
                    Picker("Domain Matcher", selection: $profile.config.routing.domainMatcher) {
                        Text("hybrid").tag("hybrid")
                        Text("linear").tag("linear")
                    }
                }
                
                Section(header: HStack {
                    Text("Rules")
                    Spacer()
                    Button(action: {
                        editingState.ruleIndex = nil
                        editingState.showingRuleEditor = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ) {
                    ForEach(profile.config.routing.rules.indices, id: \.self) { index in
                        ruleRow(for: profile.config.routing.rules[index], at: index)
                    }
                    .onMove { from, to in
                        profile.config.routing.rules.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { index in
                        profile.config.routing.rules.remove(atOffsets: index)
                    }
                }
                
                Section(header: HStack {
                    Text("Balancers")
                    Spacer()
                    Button(action: {
                        editingState.showingBalancerEditor = true
                    }) {
                        Image(systemName: "plus")
                    }
                }) {
                    ForEach((profile.config.routing.balancers).indices, id: \.self) { index in
                        balanecerRow(for: profile.config.routing.balancers[index], at: index)
                    }
                    .onMove { from, to in
                        profile.config.routing.balancers.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { index in
                        profile.config.routing.balancers.remove(atOffsets: index)
                    }
                }
                
                
                Section("Subscription") {
                    Button (action: {
                        UIPasteboard.general.string = profile.url
                    }) {
                        HStack {
                            TextField("Subscription URL", text: $profile.url)
                            Spacer()
                            Image(systemName: "doc.on.clipboard")
                        }
                    }
                    
                    Button (action: {
                        if profile.url.isEmpty {
                            if let string = UIPasteboard.general.string {
                                profile.url = string
                            }
                        }
                        Task {
                            try await updateProfile()
                        }
                    }) {
                        HStack {
                            Text("Subscribe")
                            Spacer()
                            Image(systemName: "link")
                        }
                    }
                }
                
                
                Section {
                    Button (action: { editingState.showingImport = true }) {
                        HStack {
                            Text("Import")
                            Spacer()
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                    Button (action: { editingState.showingExport = true }) {
                        HStack {
                            Text("Export")
                            Spacer()
                            Image(systemName: "arrowshape.turn.up.forward")
                        }
                    }
                }
            }
            .navigationBarTitle(navigationBarTitle, displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            .sheet(isPresented: $editingState.showingRuleEditor) {
                if let index = editingState.ruleIndex {
                    RuleView(
                        rule: profile.config.routing.rules[index],
                        proxies: profile.config.outbounds,
                        balancers: profile.config.routing.balancers,
                        onSave: { rule in
                            profile.config.routing.rules[index] = rule
                            editingState.showingRuleEditor = false
                        }
                    )
                } else {
                    RuleView(
                        proxies: profile.config.outbounds,
                        balancers: profile.config.routing.balancers,
                        onSave: { rule in
                            profile.config.routing.rules.append(rule)
                        }
                    )
                }
                
            }
            .sheet(isPresented: $editingState.showingInboundEditor) {
                if let index = editingState.inboundIndex {
                    InboundView(
                        inbound: profile.config.inbounds[index],
                        onSave: { proxy in
                            profile.config.inbounds[index] = proxy
                            editingState.showingInboundEditor = false
                        }
                    )
                } else {
                    InboundView(
                        onSave: { proxy in
                            profile.config.inbounds.append(proxy)
                            editingState.showingInboundEditor = false
                        }
                    )
                }
            }
            .sheet(isPresented: $editingState.showingQRCode) {
                if let index = editingState.outboundIndex {
                    let outbound = profile.config.outbounds[index]
                    QRCodeView(text: outbound.shareLink())
                }
            }
            .sheet(isPresented: $editingState.showingOutboundEditor) {
                if let index = editingState.outboundIndex {
                    OutboundView(
                        proxy: profile.config.outbounds[index],
                        onSave: { proxy in
                            profile.config.outbounds[index] = proxy
                            editingState.showingOutboundEditor = false
                        }
                    )
                } else {
                    OutboundView(
                        onSave: { proxy in
                            profile.config.outbounds.append(proxy)
                            editingState.showingOutboundEditor = false
                        }
                    )
                }
            }
            .sheet(isPresented: $editingState.showingBalancerEditor) {
                if let index = editingState.balancerIndex {
                    BalancerView(
                        balancer: profile.config.routing.balancers[index],
                        proxies: profile.config.outbounds,
                        onSave: { balancer in
                            profile.config.routing.balancers[index] = balancer
                        }
                    )
                } else {
                    BalancerView(
                        proxies: profile.config.outbounds,
                        onSave: { balancer in
                            profile.config.routing.balancers.append(balancer)
                        }
                    )
                }
            }
            .sheet(isPresented: $editingState.showingImport) {
                ImportView(
                    onSave: { proxies in
                        profile.config.outbounds.append(contentsOf: proxies)
                    }
                )
            }
            .shareFile(
                isPresented: $editingState.showingExport,
                document: try! JSONEncoder().encode(profile.config),
                filename: "picovpn-\(profile.name).json"
            )
        }
    }
    
    private func updateProfile() async throws {
        let proxies = try await profile.fetchProxies()
        let proxyNames = proxies.map { $0.tag }
        profile.config.outbounds.removeAll(where: { profile.subscription_proxy_names.contains($0.tag) })
        profile.subscription_proxy_names = proxyNames
        profile.config.outbounds.append(contentsOf: proxies)
    }
     
    var navigationBarTitle: String {
        if profile.name.isEmpty {
            return "Add Profile"
        }
        return profile.name
    }
    
    func inboundRow(for inbound: Inbound, at index: Int) -> some View {
        VStack (alignment: .leading) {
            Text(inbound.tag)
            Text("\(inbound.protocol) \(inbound.listen):\(String(inbound.port))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contextMenu {
            Button(action: {
                editingState.inboundIndex = index
                editingState.showingInboundEditor = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                profile.config.inbounds.remove(at: index)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func outboundRow(for outbound: Outbound, at index: Int) -> some View {
        VStack(alignment: .leading) {
            Text(outbound.tag)
            Text("\(outbound.protocol)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contextMenu{
            Button(action: {
                let link = try? profile.config.shareLinks()[index]
                UIPasteboard.general.string = link
            }){
                Label("Copy as URL", systemImage: "document.on.document")
            }
            Button(action: {
                editingState.outboundIndex = index
                editingState.showingQRCode = true
            }){
                Label("Share QRCode", systemImage: "qrcode")
            }
            Button(action: {
                editingState.outboundIndex = index
                editingState.showingOutboundEditor = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                print("Deleting proxy at index: \(index)")
                profile.config.outbounds.remove(at: index)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func ruleRow(for rule: Rule, at index: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(rule.ruleTag)
            }
            Spacer()
            Text(rule.outboundTag.isEmpty ? rule.balancerTag : rule.outboundTag)
                .font(.subheadline)
        }
        .contextMenu {
            Button(action: {
                editingState.ruleIndex = index
                editingState.showingRuleEditor = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                profile.config.routing.rules.remove(at: index)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    func balanecerRow(for balancer: Balancer, at index: Int) -> some View {
        HStack {
            Text(balancer.tag)
        }
        .contextMenu {
            Button(action: {
                editingState.balancerIndex = index
                editingState.showingBalancerEditor = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                profile.config.routing.balancers.remove(at: index)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            profile.updated_at = Date.now
            onSave?(profile)
            dismiss()
        }
        .disabled(profile.name.isEmpty)
        
    }
}
