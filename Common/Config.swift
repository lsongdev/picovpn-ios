//
//  Config.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//
import Xray
import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct Log: Codable {
    var access: String = "\(Common.accessLogPath)"
    var error: String = "\(Common.errorLogPath)"
    var loglevel: String = "warning"
}

struct Stats: Codable {
    
}

struct API: Codable {
    var tag: String = ""
    var services: [String]  = []
}

struct Policy: Codable {
    var system: PolicySystem?
}

struct PolicySystem: Codable {
    var statsInboundUplink: Bool = false
    var statsInboundDownlink: Bool = false
    var statsOutboundUplink: Bool = false
    var statsOutboundDownlink: Bool = false
    
    static var enableAll: PolicySystem {
        return PolicySystem(
            statsInboundUplink: true,
            statsInboundDownlink: true,
            statsOutboundUplink: true,
            statsOutboundDownlink: true
        )
    }
}

struct Metrics: Codable {
    var tag: String = "metrics-service"
}

struct Config: Codable {
    var log: Log?
    var api: API?
    var dns: DNS? = DNS.demo
    var stats: Stats?
    var metrics: Metrics?
    var policy: Policy?
    var routing: Routing = Routing()
    var inbounds: [Inbound] = [Inbound.socks]
    var outbounds: [Outbound] = [
        Outbound.direct,
        Outbound.block,
    ]
}

struct StreamSettings: Codable {
    var network: String = "raw"
    var security: String = "none"
    var rawSettings: RawSettings = RawSettings()
    var tlsSettings: TLSSettings = TLSSettings()
    var realitySettings: RealitySetting = RealitySetting()
    var wsSettings: WebSocketSettings = WebSocketSettings()
    var httpUpgradeSettings: HTTPUpgradeSettings = HTTPUpgradeSettings()
    
    // xhttpSettings
    // kcpSettings
    // grpcSettings
     
    private enum CodingKeys: String, CodingKey {
        case network
        case security
        case rawSettings
        case tlsSettings
        case wsSettings
        case httpUpgradeSettings
        case realitySettings
    }
    init(){}
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        network = try container.decode(String.self, forKey: .network)
        security = try container.decode(String.self, forKey: .security)
        if network == "tcp" { rawSettings =  try container.decode(RawSettings.self, forKey: .rawSettings) }
        if network == "raw" { rawSettings =  try container.decode(RawSettings.self, forKey: .rawSettings) }
        if network == "ws" { wsSettings = try container.decode(WebSocketSettings.self, forKey: .wsSettings) }
        if security == "tls" { tlsSettings = try container.decode(TLSSettings.self, forKey: .tlsSettings) }
        if security == "reality" { realitySettings = try container.decode(RealitySetting.self, forKey: .realitySettings) }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(network, forKey: .network)
        try container.encode(security, forKey: .security)
        if network == "raw" { try container.encode(rawSettings, forKey: .rawSettings) }
        if network == "ws" { try container.encode(wsSettings, forKey: .wsSettings) }
        if network == "httpupgrade" { try container.encode(httpUpgradeSettings, forKey: .httpUpgradeSettings) }
        if security == "tls" { try container.encode(tlsSettings, forKey: .tlsSettings) }
        if security == "reality" { try container.encode(realitySettings, forKey: .realitySettings) }
    }
    
}

struct RawSettings: Codable {
    
}

struct RealitySetting: Codable {
    var show: Bool = false
    var target: String = ""
    var xver: Int = 0
    var serverNames: [String] = []
    var privateKey: String = ""
    var minClientVer: String = ""
    var maxClientVer: String = ""
    var shortIds: [String] = []
    var fingerprint: String = ""
    var serverName: String = ""
    var publicKey: String = ""
    var shortId: String = ""
    var spiderX: String = ""
}

struct TLSSettings: Codable {
    var serverName: String = ""
    var rejectUnknownSni: Bool = false
    var allowInsecure: Bool = false
    var alpn: [String] = []
    var minVersion: String = ""
    var maxVersion: String = ""
    var cipherSuites: String = ""
    var certificates: [String] = []
    var disableSystemRoot: Bool = false
    var enableSessionResumption: Bool = false
    var fingerprint: String = ""
    var pinnedPeerCertificateChainSha256: [String] = []
    var curvePreferences: [String] = []
    var masterKeyLog: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case serverName
        case allowInsecure
        case alpn
        case fingerprint
    }
    init(){}
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.serverName = try container.decodeIfPresent(String.self, forKey: .serverName) ?? ""
        self.allowInsecure = try container.decodeIfPresent(Bool.self, forKey: .allowInsecure) ?? false
        self.alpn = try container.decodeIfPresent([String].self, forKey: .alpn) ?? []
        self.fingerprint = try container.decodeIfPresent(String.self, forKey: .fingerprint) ?? ""
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !alpn.isEmpty { try container.encode(alpn, forKey: .alpn) }
        if !serverName.isEmpty { try container.encode(serverName, forKey: .serverName) }
        if !fingerprint.isEmpty { try container.encode(fingerprint, forKey: .fingerprint) }
        if allowInsecure { try container.encode(allowInsecure, forKey: .allowInsecure) }
    }
}

struct WebSocketSettings: Codable {
    var acceptProxyProtocol: Bool? = false
    var path: String = ""
    var host: String = ""
    var headers: [String: String]? = [:]
    var heartbeatPeriod: Int? = 10
    
}

struct HTTPUpgradeSettings: Codable {
    var acceptProxyProtocol: Bool = false
    var path: String = ""
    var host: String = ""
    var headers: [String: String] = [:]
}

struct MuxSettings {
    var enable: Bool = false
    var concurrency: Int = 8
    var xudpConcurrency: Int = 16
    var xudpProxyUDP443: String = "reject"
}

extension Config: FileDocument {
    static var readableContentTypes = [UTType.json]
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            self = Config()
            return
        }
        self = try JSONDecoder().decode(Config.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
}

extension Config {
    func toJSONString() throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        guard let json = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(self, EncodingError.Context(
                codingPath: [],
                debugDescription: "Failed to convert JSON data to string"
            ))
        }
        return json
    }
}

struct CC1: Codable {
    var outbounds: [Outbound]
}

extension Config {
    func shareLinks() throws -> [String] {
        let config = try toJSONString()
        let res = XrayConvertXrayJsonToShareLinks(config)
        return res.split(separator: "\n").map(String.init)
    }
    
    static func parseShareLinks(_ content: String) throws -> [Outbound] {
        let res = XrayConvertShareLinksToXrayJson(content)
        let config = try JSONDecoder().decode(CC1.self, from: res.data(using: .utf8)!)
        return config.outbounds
    }
    
    mutating func importLinks(_ content: String) throws {
        let outbounds = try Config.parseShareLinks(content)
        self.outbounds.append(contentsOf: outbounds)
    }
}

extension Config {
    func writeConfig() {
        let config = try! toJSONString()
        try? config.write(to: Common.configPath, atomically: true, encoding: .utf8)
    }
    mutating func enableMetrics() {
        // print("enableMetrics")
        self.stats = Stats()
        self.metrics = Metrics()
        // policy
        self.policy = self.policy ?? Policy()
        self.policy?.system = PolicySystem.enableAll
        // create dokodemo-door inbound
        var inbound = Inbound.dokodemo
        inbound.tag = "metrics-api"
        if !self.inbounds.contains(where: { $0.tag == inbound.tag }) {
            self.inbounds.append(inbound)
        }
        
        // creare rule
        var rule = Rule()
        rule.ruleTag = "metrics-rule"
        rule.inboundTag = [inbound.tag]
        rule.outboundTag = metrics!.tag
        if !self.routing.rules.contains(where: { $0.ruleTag ==  rule.ruleTag}) {
            self.routing.rules.append(rule)
        }
    }
    mutating func disableMetrics() {
        let rule = routing.rules.first { $0.outboundTag == self.metrics?.tag }
        inbounds.removeAll(where: { rule?.inboundTag.contains($0.tag) ??  false })
        routing.rules.removeAll(where: { $0.outboundTag == self.metrics?.tag })
        stats = nil
        metrics = nil
        policy?.system = nil
    }
    func findSocksProxy() -> Inbound? {
        return self.inbounds.first { $0.protocol == "socks" }
    }
    func findMetricsPort() -> Int? {
        let rule = routing.rules.first { $0.outboundTag == self.metrics?.tag }
        return self.inbounds.first { rule?.inboundTag.contains($0.tag) ?? false }?.port
    }
}
