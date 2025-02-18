//
//  OnDemandRule.swift
//  PicoVPN
//
//  Created by Lsong on 2/21/25.
//
import SwiftUI
import NetworkExtension

struct OnDemandRule: Identifiable, Codable {
    var id: UUID = UUID()
    // var name: String = ""
    var action: RuleAction = .connect
    var network: InterfaceType = .any
    var ssids: [String] = []
    var domains: [String] = []
    var address: [String] = []
    var probeURL: String = ""
    
    enum RuleAction: String, Codable, CaseIterable {
        case connect
        case disconnect
        case ignore
        case evaluate
    }
    
    enum InterfaceType: String, Codable, CaseIterable {
        case any
        case wifi
        case cellular
        
        var neInterfaceType: NEOnDemandRuleInterfaceType {
            switch self {
            case .any: return .any
            case .wifi: return .wiFi
            case .cellular: return .cellular
            }
        }
    }
    
    static func fromNERule(_ rule: NEOnDemandRule) -> OnDemandRule {
        var out = OnDemandRule()
        switch rule.action {
        case .connect:
            out.action = RuleAction.connect
        case .disconnect:
            out.action = RuleAction.disconnect
        case .evaluateConnection:
            out.action = RuleAction.evaluate
        case .ignore:
            out.action = RuleAction.ignore
        @unknown default:
            fatalError("unhandled action")
        }
        switch rule.interfaceTypeMatch {
        case .any:
            out.network = .any
        case .wiFi:
            out.network = .wifi
        case .cellular:
            out.network = .cellular
        @unknown default:
            fatalError("unhandled action")
        }
        out.domains = rule.dnsSearchDomainMatch ?? []
        out.address = rule.dnsServerAddressMatch ?? []
        out.ssids = rule.ssidMatch ?? []
        out.probeURL = rule.probeURL?.path ?? ""
        return out
    }
    
    func toNERule() -> NEOnDemandRule {
        let rule: NEOnDemandRule
        switch action {
        case .connect:
            rule = NEOnDemandRuleConnect()
        case .disconnect:
            rule = NEOnDemandRuleDisconnect()
        case .ignore:
            rule = NEOnDemandRuleIgnore()
        case .evaluate:
            let ruleEvaluate = NEOnDemandRuleEvaluateConnection()
            // rule1.connectionRules = []
            rule = ruleEvaluate
        }
        rule.interfaceTypeMatch = network.neInterfaceType
        if !ssids.isEmpty {
            rule.ssidMatch = ssids
        }
        if !domains.isEmpty {
            rule.dnsSearchDomainMatch = domains
        }
        if !address.isEmpty {
            rule.dnsServerAddressMatch = address
        }
        if !probeURL.isEmpty {
            rule.probeURL = URL(string: probeURL)
        }
        return rule
    }
}
