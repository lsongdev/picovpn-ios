import SwiftUI

// MARK: - Profile Model
struct Profile: Identifiable, Codable {
    var id: UUID = UUID()
    var url: String = ""
    var name: String = ""
    var config: Config = Config()
    var created_at: Date = Date()
    var updated_at: Date = Date()
    
    var subscription_proxy_names: [String] = []
}

extension Profile {
    func fetchProxies() async throws -> [Outbound] {
        guard let url = URL(string: self.url) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        return try Config.parseShareLinks(content)
    }
}

extension Profile {
    static var direct: Profile {
        var profile = Profile()
        profile.name = "DIRECT"
        profile.config = Config.direct
        return profile
    }
}
