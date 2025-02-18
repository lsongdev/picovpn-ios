//
//  ShadowsocksOutboundSettings.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//

struct OutboundShadowsocksSettings: Codable {
    var servers: [OutboundShadowsocksServer] = []
    
    init(){}
    init(host: String, port: Int, pass: String, method: String){
        servers.append(OutboundShadowsocksServer(address: host, port: port, password: pass, method: method))
    }
}

struct OutboundShadowsocksServer: Codable {
    var address: String = ""
    var port: Int = 1234
    var email: String?
    var password: String = ""
    var method: String = ""
    var uot: Bool = true
    var level: Int = 0
}
