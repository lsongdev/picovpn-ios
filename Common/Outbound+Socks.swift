//
//  SocksOutboundSettings.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//

struct OutboundSocksSettings: Codable {
    var address: String = ""
    var port: Int = 1080
    var users: [OutboundSocksUser] = []
    
    init(){}
    init(host: String, port: Int, user: String, pass: String, level: Int = 0){
        self.address = host
        self.port = port
        self.users.append(OutboundSocksUser(user: user, pass: pass, level: level))
    }
}

struct OutboundSocksUser: Codable {
    var user: String = ""
    var pass: String = ""
    var level: Int = 0
}
