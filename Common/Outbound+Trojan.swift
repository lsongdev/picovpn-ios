//
//  TrojanSettings.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//

struct OutboundTrojanSettings: Codable {
    var servers: [OutboundTrojanServer] = []
    
    init(){}
    init(host: String, port: Int = 443, password: String) {
        var server = OutboundTrojanServer()
        server.address = host
        server.port = port
        server.password = password
        self.servers.append(server)
    }
}

struct OutboundTrojanServer: Codable {
    var address: String = ""
    var port: Int = 443
    var password: String = ""
}
