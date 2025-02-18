//
//  InboundView.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//
import SwiftUI
import SwiftUIX

struct InboundView: View {
    @Environment(\.dismiss) var dismiss
    @State var inbound: Inbound = Inbound()
    var onSave: ((Inbound) -> Void)
    @State private var socksSettings = InboundSocksSettings()
    @State private var httpSettings = InboundHTTPSettings()
    @State private var vlessSettings = InboundVLESSSettings()
    @State private var dokodemoDoorSettings = InboundDokodemoSettings()
    // @State private var shadowsocksSettings = InboundShadowsocksSettings()
    @State private var sniffingSettings = SniffingSettings()
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var newDomain: String = ""
    
    init (inbound: Inbound = Inbound.socks, onSave: @escaping ((Inbound) -> Void)) {
        self.onSave = onSave
        _inbound = State(initialValue: inbound)
        switch inbound.settings {
        case .http(let settings):
            _httpSettings = State(initialValue: settings)
        case .socks(let settings):
            _socksSettings = State(initialValue: settings)
        case .vless(let settings):
            _vlessSettings = State(initialValue: settings)
        case .dokodemo(let settings):
            _dokodemoDoorSettings = State(initialValue: settings)
        default:
            break
        }
    }
    
    var body: some View {
        NavigationView {
            Form{
                InputField("Name", text: $inbound.tag)
                Picker("Protocol", selection: $inbound.protocol) {
                    Text("http").tag("http")
                    Text("socks").tag("socks")
                    // Text("trojan").tag("trojan")
                    // Text("vless").tag("vless")
                    // Text("vmess").tag("vmess")
                    // Text("shadowsocks").tag("shadowsocks")
                    Text("dokodemo-door").tag("dokodemo-door")
                }
                
                Section (header: Text("Basic")) {
                    InputField("Listen", text: $inbound.listen)
                    InputField("Port", value: $inbound.port)
                }
                
                Section(header: Text("Settings")) {
                    if inbound.protocol == "socks" {
                        Toggle("Enable UDP", isOn: $socksSettings.udp)
                        
                        if socksSettings.udp {
                            InputField("Client IP", text: $socksSettings.ip, placeholder: "(Optional)")
                        }
                    }
                    if inbound.protocol == "http" {
                        Toggle("Allow Transparent", isOn: $httpSettings.allowTransparent)
                    }
                    if inbound.protocol == "dokodemo-door" {
                        InputField("Address", text: $dokodemoDoorSettings.address)
                        InputField("Port", value: $dokodemoDoorSettings.port)
                        MultiPicker("Network", selection: $dokodemoDoorSettings.networks) {
                            Text("tcp").multiPickerTag("tcp")
                            Text("udp").multiPickerTag("udp")
                        }
                        Toggle("Follow Redirect", isOn: $dokodemoDoorSettings.followRedirect)
                    }
                }
                
                Section("Sniffing") {
                    Toggle("Enable Sniffing", isOn: $sniffingSettings.enabled)
                    if sniffingSettings.enabled {
                        Toggle("Route Only", isOn: $sniffingSettings.routeOnly)
                        Toggle("Metadata Only", isOn: $sniffingSettings.metadataOnly)
                        MultiPicker("Dest Override", selection: $sniffingSettings.destOverride) {
                            Text("http").multiPickerTag("http")
                            Text("tls").multiPickerTag("tls")
                            Text("quic").multiPickerTag("quic")
                            Text("fakedns").multiPickerTag("fakedns")
                            Text("fakedns+others").multiPickerTag("fakedns+others")
                        }
                    }
                }
                
                if sniffingSettings.enabled {
                    Section("Domains excluded") {
                        ForEach(sniffingSettings.domainsExcluded, id: \.self) { domain in
                            Text(domain)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                sniffingSettings.domainsExcluded.remove(at: index)
                            }
                        }
                        HStack {
                            TextField("courier.push.apple.com", text: $newDomain)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            Spacer()
                            Button {
                                if newDomain.isEmpty { return }
                                sniffingSettings.domainsExcluded.append(newDomain)
                                newDomain = ""
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                            .disabled(newDomain.isEmpty)
                        }
                    }
                }
            }
            .navigationBarTitle(navigationBarTitle, displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
    var navigationBarTitle: String {
        if inbound.tag.isEmpty {
            return "Add Inbound"
        }
        return inbound.tag
    }
    private var saveButton: some View {
        Button("Save") {
            switch inbound.protocol {
                case "http":
                inbound.settings = .http(httpSettings)
            case "socks":
                inbound.settings = .socks(socksSettings)
            case "dokodemo-door":
                inbound.settings = .dokodemo(dokodemoDoorSettings)
            default:
                print("do not support")
            }
            onSave(inbound)
            dismiss()
        }
        .disabled(inbound.tag.isEmpty)
    }
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
}
