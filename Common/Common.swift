import Foundation
import Network

public enum Common {
    public static let packageName = "me.lsong.picovpn"
    public static let groupName = "group.\(packageName)"
    public static let tunnelName = "\(packageName).tunnel"
    
    public static let containerURL: URL = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName) else {
            fatalError("无法加载共享文件路径")
        }
        let fileManager = FileManager.default
        let directories = [
            url.appendingPathComponent("logs"),
            url.appendingPathComponent("datasets")
        ]
        for directory in directories {
            if !fileManager.fileExists(atPath: directory.path) {
                do {
                    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                    // print("Created directory: \(directory.path)")
                } catch {
                    print("Error creating directory \(directory.path): \(error)")
                }
            }
        }
        return url
    }()
    
    public static let logPath = containerURL.appendingPathComponent("logs")
    public static let configPath = containerURL.appendingPathComponent("config.json")
    public static let datasetsPath = containerURL.appendingPathComponent("datasets")
    public static let errorLogPath = logPath.appendingPathComponent("error.log").path
    public static let accessLogPath = logPath.appendingPathComponent("access.log").path
}
