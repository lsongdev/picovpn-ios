//
//  MetricsView.swift
//  PicoVPN
//
//  Created by Lsong on 2/20/25.
//
import SwiftUI
import WidgetKit

struct MetricsView: View {
    @ObservedObject private var appManager = PicoAppManager.shared
    @State private var metrics: MetricsReport?
    @State private var trafficHistory: [Date: MetricsReport] = [:]
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 总览卡片
                overviewCard
                
                // 入站流量详情
                inboundTrafficCard
                
                // 出站流量详情
                outboundTrafficCard
            }
            .padding()
        }
        .navigationBarTitle("Traffic", displayMode: .inline)
        .onReceive(timer) { _ in
            if appManager.isConnected {
                Task {
                    try await updateTrafficStats()
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    private var overviewCard: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Status", systemImage: "circle.fill")
                    .foregroundColor(appManager.isConnected ? .green : .red)
                Spacer()
                Text(timeElapsed)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // 总流量统计
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Upload")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(formatBytes(totalUplink))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Total Download")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(formatBytes(totalDownlink))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var inboundTrafficCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Inbound Traffic", systemImage: "arrow.down.circle.fill")
                    .font(.headline)
                Spacer()
            }
            
            if let inbound = metrics?.stats.inbound {
                ForEach(Array(inbound.keys).sorted(), id: \.self) { key in
                    if let traffic = inbound[key] {
                        trafficRowView(title: key, traffic: traffic)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var outboundTrafficCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Outbound Traffic", systemImage: "arrow.up.circle.fill")
                    .font(.headline)
                Spacer()
            }
            
            if let outbound = metrics?.stats.outbound {
               ForEach(Array(outbound.keys).sorted(), id: \.self) { key in
                   if let traffic = outbound[key] {
                       trafficRowView(title: key, traffic: traffic)
                   }
               }
           }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        
    }
    
    private func trafficRowView(title: String, traffic: MetricsTraffic) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(.body, design: .monospaced))
                Spacer()
            }
            
            HStack {
                HStack {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.blue)
                    Text(formatBytes(traffic.uplink))
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.green)
                    Text(formatBytes(traffic.downlink))
                }
            }
            .font(.subheadline)
            
            // 进度条显示
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    // 上传进度条
                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: geometry.size.width * CGFloat(Double(traffic.uplink) / Double(max(totalUplink, 1))))
                    
                    // 下载进度条
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: geometry.size.width * CGFloat(Double(traffic.downlink) / Double(max(totalDownlink, 1))))
                }
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
    }
    
    // MARK: - Helper Methods & Computed Properties
    
    private var totalUplink: Int {
        let inboundUplink = metrics?.stats.inbound.values.reduce(0) { $0 + $1.uplink } ?? 0
        let outboundUplink = metrics?.stats.outbound.values.reduce(0) { $0 + $1.uplink } ?? 0
        return max(inboundUplink, outboundUplink)
    }
    
    private var totalDownlink: Int {
        let inboundDownlink = metrics?.stats.inbound.values.reduce(0) { $0 + $1.downlink } ?? 0
        let outboundDownlink = metrics?.stats.outbound.values.reduce(0) { $0 + $1.downlink } ?? 0
        return max(inboundDownlink, outboundDownlink)
    }
    
    private var timeElapsed: String {
        return appManager.formattedDuration
    }
    
    private func updateTrafficStats() async throws {
        guard let port = appManager.selectedProfile?.config.findMetricsPort() else {
            return
        }
        guard let report = try? await MetricsReport.queryReport(port) else {
            return
        }
        await MainActor.run {
            metrics = report
            trafficHistory[Date()] = report
            
            // 只保留最近30个数据点
            if trafficHistory.count > 30 {
                trafficHistory.removeValue(forKey: trafficHistory.keys.sorted().first!)
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        let kilobyte = 1024.0
        let megabyte = kilobyte * 1024.0
        let gigabyte = megabyte * 1024.0
        let bytesDouble = Double(bytes)
        
        if bytes >= Int(gigabyte) {
            return String(format: "%.2f GB", bytesDouble / gigabyte)
        } else if bytes >= Int(megabyte) {
            return String(format: "%.2f MB", bytesDouble / megabyte)
        } else if bytes >= Int(kilobyte) {
            return String(format: "%.2f KB", bytesDouble / kilobyte)
        } else {
            return "\(bytes) B"
        }
    }
}
