//
//  DatasetsManager.swift
//  PicoVPN
//
//  Created by Lsong on 2/17/25.
//
import SwiftUI

// MARK: - Models
class Dataset: Identifiable, ObservableObject, Codable {
    var id = UUID()
    var type: String = ""
    var name: String = ""
    var url: String = ""
    
    @Published var isDownloading: Bool = false
    @Published var isDownloaded: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, type, name, url
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        _isDownloading = Published(initialValue: false)
        _isDownloaded = Published(initialValue: FileManager.default.fileExists(atPath: filePath.path))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
    }
    
    init(type: String, name: String, url: String) {
        self.type = type
        self.name = name
        self.url = url
        _isDownloaded = Published(initialValue: FileManager.default.fileExists(atPath: filePath.path))
    }
    
    var filePath: URL {
        Common.datasetsPath.appendingPathComponent("\(name).dat")
    }
    
    func download() async  {
        guard let url = URL(string: self.url) else {
            return
        }
        await MainActor.run {
            isDownloading = true
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            try data.write(to: filePath)
            await MainActor.run {
               self.isDownloaded = true
            }
        } catch {
            print("download error: \(error)")
        }
        await MainActor.run {
            isDownloading = false
        }
    }
    
    func delete() throws {
        if isDownloaded {
            try FileManager.default.removeItem(at: filePath)
            isDownloaded = false
        }
    }
    func hasFile() -> Bool {
        FileManager.default.fileExists(atPath: filePath.path)
    }
}


public struct GeoData: Codable {
    let categoryCount: Int
    let ruleCount: Int
    let codes: [GeoDataRow]
    
    init(categoryCount: Int = 0, ruleCount: Int = 0, codes: [GeoDataRow] = []) {
        self.categoryCount = categoryCount
        self.ruleCount = ruleCount
        self.codes = codes
    }
}

struct GeoDataRow: Codable {
    let code: String
    let ruleCount: Int
}

class DatasetsManager: ObservableObject {
    
    static var shared: DatasetsManager = .init()
    
    @Published var datasets: [Dataset] = []
    private let userDefaultsKey = "datasets"
    
    init() {
        loadDatasets()
    }
    
    func loadDatasets() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedDatasets = try? JSONDecoder().decode([Dataset].self, from: savedData) {
            datasets = decodedDatasets
        }
        if !datasets.contains(where: { $0.name == "geoip" }) {
            datasets.append(Dataset(type: "ip", name: "geoip", url: "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"))
        }
        if !datasets.contains(where: { $0.name == "geosite" }) {
            datasets.append(Dataset(type: "domain", name: "geosite", url: "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"))
        }
    }
    
    func saveDatasets() {
        if let encoded = try? JSONEncoder().encode(datasets) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func updateAllDatasets() async {
        await withTaskGroup(of: Void.self) { group in
            for dataset in datasets {
                group.addTask {
                    await dataset.download()
                }
            }
        }
    }
    
    func deleteAllFiles() {
        for dataset in datasets {
            try? dataset.delete()
        }
    }

    func validateRequiredDatasets() -> Bool {
        let requiredFiles = ["geoip", "geosite"]
        let downloadedFiles = datasets.filter { dataset in
            requiredFiles.contains(dataset.name) && dataset.hasFile()
        }
        return downloadedFiles.count == requiredFiles.count
    }
}
