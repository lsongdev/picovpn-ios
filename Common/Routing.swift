//
//  Routing.swift
//  PicoVPN
//
//  Created by Lsong on 1/22/25.
//
import SwiftUI

struct Rule: Hashable, Codable, Equatable {
    var type: String = "field"
    var ruleTag: String = ""
    var domainMatcher: String = ""
    var domain: [String] = []
    var ip: [String] = []
    var port: String = ""
    var sourcePort: String = ""
    var source: [String] = []
    var user: [String] = []
    var inboundTag: [String] = []
    var `protocol`: [String] = []
    var attrs: [String: String] = [:]
    var outboundTag: String = ""
    var balancerTag: String = ""
    var network: String = ""
    
    var networks: [String] {
        get {
            return self.network.split(separator: ",").map(String.init)
        }
        set {
            self.network = newValue.joined(separator: ",")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case domainMatcher, type, domain, ip, port
        case sourcePort, source, user, inboundTag
        case `protocol`, attrs, outboundTag, balancerTag
        case ruleTag, network
    }
    init(){}
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "field"
        ruleTag = try container.decodeIfPresent(String.self, forKey: .ruleTag) ?? ""
        network = try container.decodeIfPresent(String.self, forKey: .network) ?? ""
        domainMatcher = try container.decodeIfPresent(String.self, forKey: .domainMatcher) ?? ""
        domain = try container.decodeIfPresent([String].self, forKey: .domain) ?? []
        source = try container.decodeIfPresent([String].self, forKey: .source) ?? []
        sourcePort = try container.decodeIfPresent(String.self, forKey: .sourcePort) ?? ""
        ip = try container.decodeIfPresent([String].self, forKey: .ip) ?? []
        port = try container.decodeIfPresent(String.self, forKey: .port) ?? ""
        user = try container.decodeIfPresent([String].self, forKey: .user) ?? []
        `protocol` = try container.decodeIfPresent([String].self, forKey: .protocol) ?? []
        attrs = try container.decodeIfPresent([String: String].self, forKey: .attrs) ?? [:]
        inboundTag = try container.decodeIfPresent([String].self, forKey: .inboundTag) ?? []
        outboundTag = try container.decodeIfPresent(String.self, forKey: .outboundTag) ?? ""
        balancerTag = try container.decodeIfPresent(String.self, forKey: .balancerTag) ?? ""
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(ruleTag, forKey: .ruleTag)
        if !domainMatcher.isEmpty {
            try container.encode(domainMatcher, forKey: .domainMatcher)
        }
        if !domain.isEmpty {
            try container.encode(domain, forKey: .domain)
        }
        if !ip.isEmpty {
            try container.encode(ip, forKey: .ip)
        }
        if !port.isEmpty {
            try container.encode(port, forKey: .port)
        }
        if !sourcePort.isEmpty {
            try container.encode(sourcePort, forKey: .sourcePort)
        }
        if !source.isEmpty {
            try container.encode(source, forKey: .source)
        }
        if !user.isEmpty {
            try container.encode(user, forKey: .user)
        }
        if !`protocol`.isEmpty {
            try container.encode(`protocol`, forKey: .protocol)
        }
        if !attrs.isEmpty {
            try container.encode(attrs, forKey: .attrs)
        }
        if !inboundTag.isEmpty {
            try container.encode(inboundTag, forKey: .inboundTag)
        }
        if !outboundTag.isEmpty {
            try container.encode(outboundTag, forKey: .outboundTag)
        }
        if !balancerTag.isEmpty {
            try container.encode(balancerTag, forKey: .balancerTag)
        }
        if !network.isEmpty {
            try container.encode(network, forKey: .network)
        }
    }
    static var china_ip_direct: Rule {
        var rule = Rule()
        rule.ruleTag = "china-ip-direct"
        rule.ip = ["geoip:cn"]
        rule.outboundTag = "direct"
        return rule
    }
    static var china_domain_direct: Rule {
        var rule = Rule()
        rule.ruleTag = "china-domain-direct"
        rule.domain = ["geosite:cn"]
        rule.outboundTag = "direct"
        return rule
    }
    static var match_all: Rule {
        var rule = Rule()
        rule.ruleTag = "match-all"
        rule.port = "1-65535"
        rule.outboundTag = "proxy"
        rule.balancerTag = "proxy"
        return rule
    }
}

struct Routing: Codable {
    var domainStrategy: String = "AsIs"
    var domainMatcher: String = "hybrid"
    var balancers: [Balancer] = []
    var rules: [Rule] = [
        Rule.china_ip_direct,
        Rule.china_domain_direct,
        Rule.match_all
    ]
}

struct Balancer: Codable {
    var tag: String = ""
    var selector: [String] = []
    var fallbackTag: String = ""
    var strategy: BalancerStrategy = BalancerStrategy()
    
    static var proxy: Balancer {
        return Balancer(
            tag: "proxy",
            selector: ["^((?!direct|block).)*$"],
            fallbackTag: "direct"
        )
    }
}

struct BalancerStrategy: Codable {
    var type: String = ""
    var settings: BalancerStrategySettings?
}

struct BalancerStrategySettings: Codable {
    var expected: Int = 2
    var maxRTT: String = ""
    var tolerance: Double = 0.01
    var baselines: [String] = ["1s"]
    var costs: [CostObject] = []
}

struct CostObject: Codable {
    var regexp: Bool = false
    var match: String = ""
    var value: Double = 0.5
}
