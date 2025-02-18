import SwiftUI

// MARK: - Profile Model
struct Profile: Identifiable, Codable {
    var id: UUID = UUID()
    // var url: String = "https://s1.trojanflare.one/clashx/1b996922-00ff-4795-b867-ddcc8511b6d4"
    var subscription_proxy_names: [String] = []
    var url: String = ""
    var name: String = ""
    var config: Config = Config()
    var created_at: Date = Date()
    var updated_at: Date = Date()
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
