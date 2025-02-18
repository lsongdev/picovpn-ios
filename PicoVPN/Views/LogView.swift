
import SwiftUI

class LogManager {
    static var shared = LogManager()
    
    static func archiveLogs() {
        let fileManager = FileManager.default
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        
        let logsToArchive = ["error.log", "access.log"]
        
        for logName in logsToArchive {
            let logPath = Common.logPath.appendingPathComponent(logName)
            
            guard fileManager.fileExists(atPath: logPath.path) else { continue }
            
            let newName = logName.replacingOccurrences(of: ".log", with: "-\(timestamp).log")
            let newPath = Common.logPath.appendingPathComponent(newName)
            
            do {
                try fileManager.moveItem(at: logPath, to: newPath)
                print("Successfully archived \(logName) to \(newName)")
                
                try "".write(to: logPath, atomically: true, encoding: .utf8)
            } catch {
                print("Error archiving \(logName): \(error)")
            }
        }
    }

    static func cleanupOldLogs(olderThanDays days: Int) {
        let fileManager = FileManager.default
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        do {
            let logFiles = try fileManager.contentsOfDirectory(
                at: Common.logPath,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            for fileURL in logFiles {
                if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                   let creationDate = attributes[.creationDate] as? Date,
                   creationDate < cutoffDate {
                    try? fileManager.removeItem(at: fileURL)
                    print("Deleted old log: \(fileURL.lastPathComponent)")
                }
            }
        } catch {
            print("Error cleaning up logs: \(error)")
        }
    }
}

struct LogView: View {
    @ObservedObject private var appManager = PicoAppManager.shared
    @State private var files: [String] = []
    
    
    var body: some View {
        List {
            
            Section {
                Toggle("Auto Delete", isOn: $appManager.autoDeleteLogs)
                if appManager.autoDeleteLogs {
                    Stepper(value: $appManager.deleteLogAfterDays, in: 1...60) {
                        Text("Delete log after \(appManager.deleteLogAfterDays) days")
                    }
                }
            }
            
            ForEach(files, id: \.self) { log in
                NavigationLink(destination: LogViewer(filename: log)) {
                    Text(log)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    deleteLog(name: files[index])
                }
                files.remove(atOffsets: indexSet)
            }
            
            if files.isEmpty {
                Text("No logs found.")
            }
            
            Section {
                Button(role: .destructive, action: clearAllLogs) {
                    HStack {
                        Text("Clear all logs")
                        Spacer()
                        Image(systemName: "trash")
                    }
                }
                .foregroundColor(.red)
            }
            
        }
        .onAppear {
            loadLogs()
        }
        .navigationBarTitle("Logs", displayMode: .inline)
    }
    
    private func deleteLog(name: String) {
        let logPath = Common.logPath.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: logPath)
    }
    
    private func clearAllLogs() {
        for file in files {
            deleteLog(name: file)
        }
        files.removeAll()
    }
    
    private func loadLogs() {
        do {
            files = try FileManager.default.contentsOfDirectory(at: Common.logPath, includingPropertiesForKeys: nil).map { $0.lastPathComponent }
            .filter { $0.hasSuffix(".log") }
            .sorted(by: >)
        } catch {
            print("Error loading logs: \(error)")
        }
    }
}
