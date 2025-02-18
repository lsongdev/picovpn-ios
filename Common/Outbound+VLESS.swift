//
//  VLESSSettings.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//
import SwiftUI

struct OutboundVLESSSettings: Codable {
    var vnext: [OutboundVLESSServer] = []
    
    init(){}
    init(host: String, port: Int, user: String, encryption: String = "", flow: String = "", level: Int = 0) {
        var server = OutboundVLESSServer(address: host, port: port)
        server.users.append(OutboundVLESSUser(
            id: user,
            encryption: encryption,
            flow: flow,
            level: level
        ))
        self.vnext.append(server)
    }
}

struct OutboundVLESSServer: Codable {
    var address: String = ""
    var port: Int = 443
    var users: [OutboundVLESSUser] = []
}

struct OutboundVLESSUser: Codable {
    var id: String = ""
    var encryption: String = "none"
    var flow: String? = ""
    var level: Int? = 0
}
