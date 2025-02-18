//
//  InboundDokodemoSettings.swift
//  PicoVPN
//
//  Created by Lsong on 2/12/25.
//

struct InboundDokodemoSettings: Codable {
    var address: String = "127.0.0.1"
    var port: Int = 0
    var network: String = "tcp"
    var followRedirect: Bool = false
    var userLevel: Int = 0
    
    var networks: [String] {
        set {
            self.network = newValue.joined(separator: ",")
        }
        get {
            return self.network.split(separator: ",").map(String.init)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case port
        case network
        case followRedirect
        case userLevel
    }
    init(){}
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        port = try container.decodeIfPresent(Int.self, forKey: .port) ?? 0
        network = try container.decodeIfPresent(String.self, forKey: .network) ?? "tcp"
        followRedirect = try container.decodeIfPresent(Bool.self, forKey: .followRedirect) ?? false
        userLevel = try container.decodeIfPresent(Int.self, forKey: .userLevel) ?? 0
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        if port != 0 {
            try container.encode(port, forKey: .port)
        }
        if network != "tcp" {
            try container.encode(network, forKey: .network)
        }
        if followRedirect {
            try container.encode(followRedirect, forKey: .followRedirect)
        }
        if userLevel != 0 {
            try container.encode(userLevel, forKey: .userLevel)
        }
    }
}
