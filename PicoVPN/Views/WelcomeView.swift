import SwiftUI

struct WelcomeView: View {
    @ObservedObject var appManager: PicoAppManager = PicoAppManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("Welcome to \(appManager.appName)")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Secure, Fast & Simple VPN Service")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                                
                VStack(alignment: .leading, spacing: 24) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Lightning Fast")
                                .font(.headline)
                            Text("Optimized performance with XRAY")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                    }
                    
                    Label {
                        VStack(alignment: .leading) {
                            Text("Secure & Private")
                                .font(.headline)
                            Text("Protect your online privacy")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                    }
                    
                    Label {
                        VStack(alignment: .leading) {
                            Text("Easy to Use")
                                .font(.headline)
                            Text("One-click connection and setup")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "hand.tap.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Spacer()
                

                Button {
                    Task {
                        isLoading = true
                        await DatasetsManager.shared.updateAllDatasets()
                        isLoading = false
                        dismiss()
                    }
                } label: {
                    HStack (alignment: .center) {
                        if isLoading {
                            ProgressView().controlSize(.small)
                        }
                        Text(isLoading ? "Loading..." : "Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundStyle(.background)
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.horizontal)
                .disabled(isLoading)
            }
            .padding()
            .navigationTitle("Welcome")
            .toolbar(.hidden)
        }
    }
}
