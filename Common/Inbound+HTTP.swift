//
//  Inbound+HTTP.swift
//  PicoVPN
//
//  Created by Lsong on 2/12/25.
//

struct InboundHTTPSettings: Codable {
    var allowTransparent: Bool = false
    var userLevel: Int = 0
    var accounts: [InboundHTTPAccount] = []
}

struct InboundHTTPAccount: Codable {
    var user: String = ""
    var pass: String = ""
}
