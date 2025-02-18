//
//  Outbound.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//

import SwiftUI

enum OutboundSetting {
    case http(OutboundHTTPSettings)
    case socks(OutboundSocksSettings)
    case vless(OutboundVLESSSettings)
    case vmess(OutboundVMESSSettings)
    case trojan(OutboundTrojanSettings)
    case shadowsocks(OutboundShadowsocksSettings)
    case freedom(OutboundFreedomSettings)
    case blackhole(OutboundBlackholeSettings)    
}

struct Outbound: Codable {
    var tag: String = ""
    var `protocol`: String = "freedom"
    var settings: OutboundSetting = .freedom(OutboundFreedomSettings())
    var streamSettings: StreamSettings = StreamSettings()
    var mux: MuxSettings?
    
    var type: String {
        get { return self.protocol }
        set {
            if newValue == "trojan" {
                streamSettings.network = "raw"
                streamSettings.security = "tls"
            }
            self.protocol = newValue
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case tag
        case sendThrough
        case `protocol`
        case settings
        case streamSettings
    }
    
    init() {}
    init(name: String, protocol: String) {
        self.tag = name
        self.protocol = `protocol`
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tag = try container.decode(String.self, forKey: .tag)
        tag = tag.isEmpty ? try container.decode(String.self, forKey: .sendThrough) : tag
        `protocol` = try container.decode(String.self, forKey: .protocol)
        streamSettings = try container.decode(StreamSettings.self, forKey: .streamSettings)
        switch `protocol` {
        case "http":
            let httpSettings = try container.decode(OutboundHTTPSettings.self, forKey: .settings)
            settings = .http(httpSettings)
        case "socks":
            let socksSettings = try container.decode(OutboundSocksSettings.self, forKey: .settings)
            settings = .socks(socksSettings)
        case "vmess":
            let vmessSettings = try container.decode(OutboundVMESSSettings.self, forKey: .settings)
            settings = .vmess(vmessSettings)
        case "vless":
            let vlessSettings = try container.decode(OutboundVLESSSettings.self, forKey: .settings)
            settings = .vless(vlessSettings)
        case "trojan":
            let trojanSettings = try container.decode(OutboundTrojanSettings.self, forKey: .settings)
            settings = .trojan(trojanSettings)
            streamSettings.network = "raw"
            streamSettings.security = "tls"
        case "freedom":
            let freedomSettings = try container.decode(OutboundFreedomSettings.self, forKey: .settings)
            settings = .freedom(freedomSettings)
        case "blackhole":
            let blackholeSettings = try container.decode(OutboundBlackholeSettings.self, forKey: .settings)
            settings = .blackhole(blackholeSettings)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .protocol,
                in: container,
                debugDescription: "Unsupported protocol: \(`protocol`)"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tag, forKey: .tag)
        try container.encode(`protocol`, forKey: .protocol)
        try container.encode(streamSettings, forKey: .streamSettings)
        
        // 根据设置类型编码
        switch settings {
        case .socks(let settings):
            try container.encode(settings, forKey: .settings)
        case .vless(let settings):
            try container.encode(settings, forKey: .settings)
        case .vmess(let settings):
            try container.encode(settings, forKey: .settings)
        case .trojan(let settings):
            try container.encode(settings, forKey: .settings)
        case .shadowsocks(let settings):
            try container.encode(settings, forKey: .settings)
        case .freedom(let settings):
            try container.encode(settings, forKey: .settings)
        case .blackhole(let settings):
            try container.encode(settings, forKey: .settings)
        case .http(let settings):
            try container.encode(settings, forKey: .settings)
        }
    }
    var isValid: Bool {
        return !tag.isEmpty
    }
    static var direct : Outbound {
        var outbound = Outbound()
        outbound.tag = "direct"
        outbound.protocol = "freedom"
        return outbound
    }
    static var block: Outbound {
        var outbound = Outbound()
        outbound.tag = "block"
        outbound.protocol = "blackhole"
        return outbound
    }
}

extension Outbound {
    func shareLink() -> String {
        var config = Config()
        config.outbounds = [self]
        let link = try? config.shareLinks().first!
        return link!
    }
}
