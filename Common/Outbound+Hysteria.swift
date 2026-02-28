//
//  Outbound+Hysteria.swift
//  PicoVPN
//
//  Created by Lsong on 2/28/26.
//
// @docs https://xtls.github.io/config/outbounds/hysteria.html
struct OutboundHysteriaSettings: Codable {
    var version: String = "2" // MUST 2
    var address: String = ""
    var port: Int = 443
}
