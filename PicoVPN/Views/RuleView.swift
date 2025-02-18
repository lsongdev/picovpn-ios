import SwiftUI
import SwiftUIX

struct RuleView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var appManager = PicoAppManager.shared
    
    @State var rule: Rule = Rule()
    @State private var newDomain: String = ""
    @State private var newIP: String = ""
    @State private var newSource: String = ""
    @State private var newUser: String = ""
    @State private var newInboundTag: String = ""
    
    var proxies: [Outbound]
    var balancers: [Balancer]
    var onSave: ((Rule) -> Void)?
    
    let domainMatcherTypes = ["hybrid", "linear"]
    let networkTypes = ["tcp", "udp"]
    let protocols = ["http", "tls", "bittorrent"]
    
    var body: some View {
        NavigationView {
            Form {
                InputField("Name", text: $rule.ruleTag, placeholder: "rule name")
                
                Section(header: Text("Domain")) {
                    Picker("Domain Matcher", selection: $rule.domainMatcher) {
                        Text("<empty>").tag("")
                        ForEach(domainMatcherTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    ForEach(rule.domain, id: \.self) { domain in
                        Text(domain)
                    }
                    .onDelete { index in
                        rule.domain.remove(atOffsets: index)
                    }
                    
                    HStack {
                        TextField("Add domain", text: $newDomain)
                        Button {
                            if !newDomain.isEmpty {
                                rule.domain.append(newDomain)
                                newDomain = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(newDomain.isEmpty)
                    }
                }
                
                MultiPicker("Network", selection: $rule.networks) {
                    ForEach(networkTypes, id: \.self) {
                        Text($0)
                            .multiPickerTag($0)
                    }
                }
                
                Section(header: Text("Source Address")) {
                    ForEach(rule.source, id: \.self) { ip in
                        Text(ip)
                    }
                    
                    HStack {
                        TextField("Add IP/CIDR", text: $newIP)
                        Button {
                            if !newIP.isEmpty {
                                rule.source.append(newIP)
                                newIP = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(newIP.isEmpty)
                    }
                }
                
                Section(header: Text("Target Address")) {
                    ForEach(rule.ip, id: \.self) { ip in
                        Text(ip)
                    }
                    .onDelete { index in
                        rule.ip.remove(atOffsets: index)
                    }
                    
                    HStack {
                        TextField("Add IP/CIDR", text: $newIP)
                        Button {
                            if !newIP.isEmpty {
                                rule.ip.append(newIP)
                                newIP = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(newIP.isEmpty)
                    }
                }
                
                Section(header: Text("Port")) {
                    InputField("Source Port", text: $rule.sourcePort)
                    InputField("Target Port", text: $rule.port, placeholder: "e.g., 53,443,1000-2000")
                }
                
                Section (footer: Text("* sniffing required")) {
                    MultiPicker("Protocol", selection: $rule.protocol) {
                        ForEach(protocols, id: \.self) {
                            Text($0)
                                .multiPickerTag($0)
                        }
                    }
                }
                
                Section("Inbound Tag") {
                    ForEach(rule.inboundTag, id: \.self) { inboundTag in
                        Text(inboundTag)
                    }
                    .onDelete { index in
                        rule.inboundTag.remove(atOffsets: index)
                    }
                    
                    HStack {
                        TextField("Inbound Tag", text: $newInboundTag)
                        Button {
                            if !newInboundTag.isEmpty {
                                rule.inboundTag.append(newInboundTag)
                                newInboundTag = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(newInboundTag.isEmpty)
                    }
                }
               
                Section(
                    header: Text("Proxy"),
                    footer: Text("You must choose either balancerTag or outboundTag. If both are specified, only outboundTag will be applied.")) {
                        PickerInput("Outbound", text: $rule.outboundTag, options: proxies.map{ $0.tag })
                        PickerInput("Balancer", text: $rule.balancerTag, options: balancers.map{ $0.tag })
                    
                }
            }
            .navigationBarTitle(navigationBarTitle, displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
    
    var navigationBarTitle: String {
        if rule.ruleTag.isEmpty {
            return "Add Rule"
        }
        return rule.ruleTag
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            onSave?(rule)
            dismiss()
        }
        .disabled(rule.ruleTag.isEmpty)
    }
}
