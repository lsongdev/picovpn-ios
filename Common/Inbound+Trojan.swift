//
//  TrojanInboundSettings.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//
import SwiftUI
//
struct InboundTrojanSettings: Codable {
    var clients: [InboundTrojanClient] = []
    var fallbacks: [InboundTrojanFallback]?
}

struct InboundTrojanClient: Codable {
    var password: String
    var email: String?
    var level: Int
}

struct InboundTrojanFallback: Codable {
    var dest: Int
    var xver: Int?
    var alpn: String?
}
