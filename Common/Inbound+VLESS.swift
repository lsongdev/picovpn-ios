//
//  VLESSInboundSettings.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//
import SwiftUI
//
struct InboundVLESSSettings: Codable {
    var decryption: String = ""
    var clients: [InboundVLESSClient] = []
    var fallbacks: [InboundVLESSFallback]?
}

struct InboundVLESSClient: Codable {
    var id: String
    var level: Int
    var email: String?
    var flow: String?
}

struct InboundVLESSFallback: Codable {
    var dest: Int
    var xver: Int?
    var alpn: String?
    var path: String?
}
