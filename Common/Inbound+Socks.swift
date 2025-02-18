//
//  SocksInboundSettings.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//

struct InboundSocksSettings: Codable {
    var udp: Bool = false
    var ip: String = ""
    
    enum CodingKeys: CodingKey {
        case udp
        case ip
    }
    init(udp: Bool = false) {
        self.udp = udp
    }
    init (from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        udp = try container.decodeIfPresent(Bool.self, forKey: .udp) ?? false
        ip = try container.decodeIfPresent(String.self, forKey: .ip) ?? ""
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if udp {
            try container.encode(udp, forKey: .udp)
        }
        if udp && !ip.isEmpty {
            try container.encode(ip, forKey: .ip)
        }
    }
}
