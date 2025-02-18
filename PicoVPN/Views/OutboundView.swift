import SwiftUI
import SwiftUIX

let fingerprints = [
    "chrome",
    "firefox",
    "safari",
    "ios",
    "android",
    "edge",
    "360",
    "qq",
    "random",
    "randomized",
]
let protocols = [ "vmess", "vless", "trojan", "shadowsocks", "http", "socks", "freedom", "blackhole"]
let securityTypes = ["none", "tls", "reality"]
let networkTypes = [ "raw", "xhttp", "kcp", "grpc", "ws", "httpupgrade" ]
let supportedMethods = [
    "shadowsocks": [
        "2022-blake3-aes-128-gcm",
        "2022-blake3-aes-256-gcm",
        "2022-blake3-chacha20-poly1305",
        "aes-256-gcm",
        "aes-128-gcm",
        "chacha20-poly1305",
        "chacha20-ietf-poly1305",
        "xchacha20-poly1305",
        "xchacha20-ietf-poly1305",
        "plain",
        "none"
    ],
    "vmess": ["aes-128-gcm", "chacha20-poly1305", "auto", "none", "zero"],
    "vless": ["none"]
]

let domainStrategies = [
    "AsIs",
    "UseIP",
    "UseIPv6v4",
    "UseIPv6",
    "UseIPv4v6",
    "UseIPv4",
    "ForceIP" ,
    "ForceIPv6v4",
    "ForceIPv6",
    "ForceIPv4v6",
    "ForceIPv4"
]

struct OutboundView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appManager: PicoAppManager
    @State var proxy: Outbound = Outbound()
    @State var muxSettings: MuxSettings = MuxSettings()
    @State var address: String = ""
    @State var port: Int = 443
    @State var username: String = ""
    @State var password: String = ""
    @State var alterId: Int = 64
    @State var encryption: String = "none"
    @State var responseType: String = "none"
    @State var domainStrategy = ""
    
    var onSave: ((Outbound) -> Void)?
    
    init(proxy: Outbound = Outbound(), onSave: ((Outbound) -> Void)? = nil) {
        _proxy = State(initialValue: proxy)
        
        switch proxy.settings {
        case .socks(let settings):
            _address = State(initialValue: settings.address)
            _port = State(initialValue: settings.port)
            _username = State(initialValue: settings.users.first!.user)
            _password = State(initialValue: settings.users.first!.pass)
        case .vless(let settings):
            _address = State(initialValue: settings.vnext.first!.address)
            _port = State(initialValue: settings.vnext.first!.port)
            _username = State(initialValue: settings.vnext.first!.users.first!.id)
            _encryption = State(initialValue: settings.vnext.first!.users.first!.encryption)
        case .vmess(let settings):
            _address = State(initialValue: settings.vnext.first!.address)
            _port = State(initialValue: settings.vnext.first!.port)
            _username = State(initialValue: settings.vnext.first!.users.first!.id)
        case .trojan(let settings):
            _address = State(initialValue: settings.servers.first!.address)
            _port = State(initialValue: settings.servers.first!.port)
            _password = State(initialValue: settings.servers.first!.password)
        case .shadowsocks(let settings):
            _address = State(initialValue: settings.servers.first!.address)
            _port = State(initialValue: settings.servers.first!.port)
            _password = State(initialValue: settings.servers.first!.password)
            _encryption = State(initialValue: settings.servers.first!.method)
        default:
            break
        }
        self.onSave = onSave
        
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Base settings
                InputField("Name", text: $proxy.tag, placeholder: "proxy name")
                Picker("Protocol", selection: $proxy.type) {
                    ForEach(protocols, id: \.self) { proto in
                        Text(proto).tag(proto)
                    }
                }
                
                // Server settings
                Section("Basic") {
                    if proxy.protocol != "freedom" && proxy.protocol != "blackhole" {
                        serverSettingsSection
                    }
                    
                    if proxy.protocol == "blackhole" {
                        Picker("Response", selection: $responseType) {
                            Text("none").tag("none")
                            Text("http").tag("http")
                        }
                    }
                    
                    if proxy.protocol == "freedom" {
                        Picker("Domain Strategy", selection: $domainStrategy) {
                            Text("<empty>").tag("")
                            ForEach(domainStrategies, id: \.self) { strategy in
                                Text(strategy).tag(strategy)
                            }
                        }
                    }
                }
                
                // Transport settings
                Section("Transport") {
                    Picker("Network", selection: $proxy.streamSettings.network) {
                        ForEach(networkTypes, id: \.self) { network in
                            Text(network).tag(network)
                        }
                    }
                    
                    if proxy.streamSettings.network == "ws" {
                        InputField("Host", text: $proxy.streamSettings.wsSettings.host)
                        InputField("Path", text: $proxy.streamSettings.wsSettings.path)
                    }
                    if proxy.streamSettings.network == "httpupgrade" {
                        InputField("Host", text: $proxy.streamSettings.httpUpgradeSettings.host)
                        InputField("Path", text: $proxy.streamSettings.httpUpgradeSettings.path)
                    }
                }
                
                // Security settings
                Section("Security") {
                    Picker("Security", selection: $proxy.streamSettings.security) {
                        ForEach(securityTypes, id: \.self) { security in
                            Text(security).tag(security)
                        }
                    }
                    
                    if proxy.streamSettings.security == "tls" {
                        // InputField("Fingerprint", text: $proxy.streamSettings.tlsSettings.fingerprint)
                        Picker("Fingerprint", selection: $proxy.streamSettings.tlsSettings.fingerprint) {
                            Text("<empty>").tag("")
                            ForEach(fingerprints, id: \.self) { fingerprint in
                                Text(fingerprint).tag(fingerprint)
                            }
                        }
                        MultiPicker("ALPN", selection: $proxy.streamSettings.tlsSettings.alpn) {
                            Text("H2").multiPickerTag("h2")
                            Text("H3").multiPickerTag("h3")
                            Text("HTTP 1.1").multiPickerTag("http/1.1")
                        }
                        Toggle("Allow Insecure", isOn: $proxy.streamSettings.tlsSettings.allowInsecure)
                    }
                    
                    if proxy.streamSettings.security == "reality" {
                        Picker("Fingerprint", selection: $proxy.streamSettings.realitySettings.fingerprint) {
                            Text("<empty>").tag("")
                            ForEach(fingerprints, id: \.self) { fingerprint in
                                Text(fingerprint).tag(fingerprint)
                            }
                        }
                    }
                }
                
                Section("Mux Settings") {
                    Toggle("Enable MUX", isOn: $muxSettings.enable)
                    if muxSettings.enable {
                        InputField("concurrency", value: $muxSettings.concurrency, placeholder: "8")
                        InputField("xudpConcurrency", value: $muxSettings.xudpConcurrency, placeholder: "16")
                        Picker("xudpProxyUDP443", selection: $muxSettings.xudpProxyUDP443) {
                            Text("allow").tag("allow")
                            Text("reject").tag("reject")
                            Text("skip").tag("skip")
                        }
                    }
                }
            }
            .navigationBarTitle(navigationBarTitle, displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
    
    private var serverSettingsSection: some View {
        Group {
            InputField("Host", text: $address, placeholder: "server name")
            InputField("Port", value: $port, placeholder: "server port")
                .keyboardType(.numberPad)
            
            if proxy.type == "socks" || proxy.type == "http" {
                InputField("Username", text: $username, placeholder: "username")
            }
            if proxy.type == "shadowsocks" || proxy.type == "trojan" || proxy.type == "socks" || proxy.type == "http" {
                InputField("Password", text: $password, placeholder: "password")
            }
            
            if proxy.type == "vless" || proxy.type == "vmess" {
                InputField("UUID", text: $username, placeholder: "45a84d2a-2a7a-4b48-9b07-882f0023f600")
                if proxy.type == "vmess" {
                    InputField("Alter ID", value: $alterId, placeholder: "64")
                        .keyboardType(.numberPad)
                }
            }
            if proxy.type == "shadowsocks" || proxy.type == "vmess" || proxy.type == "vless" {
                Picker("Method", selection: $encryption) {
                    ForEach(supportedMethods[proxy.protocol] ?? [], id: \.self) { method in
                        Text(method).tag(method)
                    }
                }
            }
        }
    }
    
    private var navigationBarTitle: String {
        proxy.tag.isEmpty ? "Add Outbound" : proxy.tag
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            switch proxy.type {
            case "http":
                proxy.settings = OutboundSetting.http(OutboundHTTPSettings(host: address, port: port, user: username, pass: password))
            case "socks":
                proxy.settings = OutboundSetting.socks(OutboundSocksSettings(host: address, port: port, user: username, pass: password))
            case "vmess":
                proxy.settings = OutboundSetting.vmess(OutboundVMESSSettings(host: address, port: port, user: username, security: encryption))
            case "vless":
                proxy.settings = OutboundSetting.vless(OutboundVLESSSettings(host: address, port: port, user: username, encryption: encryption))
            case "trojan":
                proxy.settings = OutboundSetting.trojan(OutboundTrojanSettings(host: address, port: port, password: password))
            case "shadowsocks":
                proxy.settings = OutboundSetting.shadowsocks(OutboundShadowsocksSettings(host: address, port: port, pass: password, method: encryption))
            case "blackhole":
                proxy.settings = OutboundSetting.blackhole(OutboundBlackholeSettings(responseType: responseType))
            default:
                proxy.settings = OutboundSetting.freedom(OutboundFreedomSettings())
            }
            if muxSettings.enable {
                proxy.mux = muxSettings
            }
            onSave?(proxy)
            dismiss()
        }
        .disabled(proxy.tag.isEmpty)
    }
}
