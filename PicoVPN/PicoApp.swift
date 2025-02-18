import SwiftUI

// MARK: - View Models

// MARK: - Views

@main
struct PicoApp: App {
    @State var appManager = PicoAppManager()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appManager)
        }
    }
}
