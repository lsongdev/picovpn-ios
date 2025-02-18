import Xray
import SwiftUI
import Foundation

enum InboundSetting {
    case http(InboundHTTPSettings)
    case socks(InboundSocksSettings)
    case vless(InboundVLESSSettings)
    case trojan(InboundTrojanSettings)
    case dokodemo(InboundDokodemoSettings)
    // case vmess(InboundVMESSSettings)
    // case shadowsocks(InboundShadowsocksSettings)
}

struct Inbound: Codable {
    var tag: String = ""
    var `protocol`: String = "socks"
    var listen: String = "127.0.0.1"
    var port: Int = 1080
    var settings: InboundSetting = .socks(InboundSocksSettings())
    var sniffing: SniffingSettings?
    
    private enum CodingKeys: String, CodingKey {
        case tag
        case `protocol`
        case listen
        case port
        case settings
    }
    
    init(){}
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tag = try container.decode(String.self, forKey: .tag)
        self.listen = try container.decode(String.self, forKey: .listen)
        self.port = try container.decode(Int.self, forKey: .port)
        self.protocol = try container.decode(String.self, forKey: .`protocol`)
        switch self.protocol {
        case "socks":
            let socksSetting = try container.decode(InboundSocksSettings.self, forKey: .settings)
            self.settings = .socks(socksSetting)
        case "dokodemo-door":
            let dokodemoSetting = try container.decode(InboundDokodemoSettings.self, forKey: .settings)
            self.settings = .dokodemo(dokodemoSetting)
        case "vless":
            let vlessSetting = try container.decode(InboundVLESSSettings.self, forKey: .settings)
            self.settings = .vless(vlessSetting)
        case "trojan":
            let trojanSetting = try container.decode(InboundTrojanSettings.self, forKey: .settings)
            self.settings = .trojan(trojanSetting)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .protocol,
                in: container,
                debugDescription: "Unsupported protocol: \(`protocol`)"
            )
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.tag, forKey: .tag)
        try container.encode(self.listen, forKey: .listen)
        try container.encode(self.port, forKey: .port)
        try container.encode(self.protocol, forKey: .`protocol`)
        switch settings {
        case .socks(let settings):
            try container.encode(settings, forKey: .settings)
        case .dokodemo(let settings):
            try container.encode(settings, forKey: .settings)
        case .vless(let settings):
            try container.encode(settings, forKey: .settings)
        case .trojan(let settings):
            try container.encode(settings, forKey: .settings)
        case .http(let settings):
            try container.encode(settings, forKey: .settings)
        }
    }
    
    static var socks: Inbound {
        var inbound = Inbound()
        inbound.port = XrayGetFreePort()
        inbound.protocol = "socks"
        inbound.tag = "entry"
        inbound.settings = .socks(InboundSocksSettings(udp: true))
        return inbound
    }
    static var dokodemo: Inbound {
        var inbound = Inbound()
        
        inbound.port = XrayGetFreePort()
        inbound.protocol = "dokodemo-door"
        inbound.tag = "entry-\(inbound.port)"
        inbound.settings = .dokodemo(InboundDokodemoSettings())
        return inbound
    }
}

struct SniffingSettings: Codable {
    var enabled: Bool = false
    var destOverride: [String] = []
    var metadataOnly: Bool = false
    var domainsExcluded: [String] = [
        "push.apple.com",
        "courier.push.apple.com",
        "dlg.io.mi.com"
    ]
    var routeOnly: Bool = false
}
