import WidgetKit
import SwiftUI
import NetworkExtension

// MARK: - Data Models
struct VPNStats {
    let uplink: Int
    let downlink: Int
}

struct WidgetEntry: TimelineEntry {
    let date: Date = Date()
}

// MARK: - Widget Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        Task {
            completion(WidgetEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let entry = WidgetEntry()
            let nextUpdate = Date().addingTimeInterval(3)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

// MARK: - Widget Views
struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        // Traffic Stats
        VStack() {
            TrafficStatBox(
                title: "Upload",
                icon: "arrow.up.circle.fill",
                color: .blue,
                value: 1
                // value: entry.stats.uplink
            )
            Spacer()
            
            TrafficStatBox(
                title: "Download",
                icon: "arrow.down.circle.fill",
                color: .green,
                value: 2
                // value: entry.stats.downlink
            )
        }
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        // Traffic Stats Column
        VStack() {
            TrafficStatBox(
                title: "Upload",
                icon: "arrow.up.circle.fill",
                color: .blue,
                value: 1
                // value: entry.stats.uplink
            )
            
            TrafficStatBox(
                title: "Download",
                icon: "arrow.down.circle.fill",
                color: .green,
                value: 2
                // value: entry.stats.downlink
            )
        }
    }
}

struct TrafficStatBox: View {
    let title: String
    let icon: String
    let color: Color
    let value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(formatBytes(value))
                    .font(.system(.callout, design: .monospaced))
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
//        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Widget Entry View
struct PicoWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            MediumWidgetView(entry: entry)
        case .systemExtraLarge:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            MediumWidgetView(entry: entry)
        case .accessoryRectangular:
            MediumWidgetView(entry: entry)
        case .accessoryInline:
            MediumWidgetView(entry: entry)
        @unknown default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration
struct PicoWidget: Widget {
    static let kind = "PicoWidget"

    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: Provider()) { entry in
            PicoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("PicoVPN Status")
        .description("Monitor VPN connection status and traffic.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Helper Functions
private func formatBytes(_ bytes: Int) -> String {
    let units = ["B", "KB", "MB", "GB"]
    var value = Double(bytes)
    var unitIndex = 0
    
    while value >= 1024 && unitIndex < units.count - 1 {
        value /= 1024
        unitIndex += 1
    }
    
    return String(format: "%.1f %@", value, units[unitIndex])
}
