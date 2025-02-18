//
//  ReportMetrics.swift
//  PicoVPN
//
//  Created by Lsong on 2/21/25.
//
import SwiftUI

public struct MetricsReport: Codable {
    let stats: MetricsStats
}

struct MetricsStats: Codable {
    let inbound: [String: MetricsTraffic]
    let outbound: [String: MetricsTraffic]
}

struct MetricsTraffic: Codable {
    let uplink: Int
    let downlink: Int
}

extension MetricsReport {
    static func queryReport(_ port: Int) async throws -> MetricsReport {
        let url = URL(string: "http://127.0.0.1:\(port)/debug/vars")!
        let urlSession = URLSession.shared
        let (data, _) = try await urlSession.data(from: url)
        return try JSONDecoder().decode(MetricsReport.self, from: data)
    }
}
