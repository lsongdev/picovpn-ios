//
//  OutboundBlackholeSettings.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//

struct OutboundBlackholeSettings: Codable {
    var response: OutboundBlackholeResponse?
    
    init(responseType: String) {
        response = OutboundBlackholeResponse()
        response!.type = responseType
    }
}

struct OutboundBlackholeResponse: Codable {
    var type: String = "none"
}
