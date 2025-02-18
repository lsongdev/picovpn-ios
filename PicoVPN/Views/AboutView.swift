import Xray
import SwiftUI

struct CreditsView: View {
    private let dependencies = [
        DependencyInfo(name: "Xray-core",
                      description: "Core functionality library for Xray.",
                      url: "https://github.com/lsongdev/xray-core",
                      license: "MPL-2.0 License"),
        DependencyInfo(name: "HevSocks5Tunnel",
                      description: "A lightweight and powerful SOCKS5 proxy implementation.",
                      url: "https://github.com/lsongdev/hev-socks5-tunnel",
                      license: "GPL-3.0 License"),
        DependencyInfo(name: "Tun2SocksKit",
                      description: "A framework for handling TUN interface to SOCKS proxy conversion.",
                      url: "https://github.com/lsongdev/Tun2SocksKit",
                      license: "MIT License"),
        DependencyInfo(name: "CodeScanner",
                      description: "An open source library that enables barcode scanning capabilities.",
                      url: "https://github.com/twostraws/CodeScanner",
                      license: "MIT License"),
        
    ]
    
    var body: some View {
        List {
            Section(header: Text("Third-Party Libraries")) {
                ForEach(dependencies) { dependency in
                    Link(destination: URL(string: dependency.url)!) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(dependency.name)
                                Text(dependency.license)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Section(header: Text("Legal")) {
                Text("These libraries are included in accordance with their respective licenses. Full license texts are available in the detailed view for each library.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Acknowledgements")
        .listStyle(InsetGroupedListStyle())
    }
}

// 依赖项信息模型
struct DependencyInfo: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let url: String
    let license: String
}

// 预览
#Preview {
    NavigationView {
        CreditsView()
    }
}

struct AboutView: View {
    @EnvironmentObject var appManager: PicoAppManager
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appManager.appName)
                            .font(.headline)
                        Text("Version \(appManager.appVersion)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section {
                HStack {
                    Text("Core Version")
                    Spacer()
                    Text(XrayVersion())
                        .foregroundColor(.secondary)
                }
                
                NavigationLink(destination: CreditsView()) {
                    Text("Acknowledgements")
                }
            }
            
            // Additional Info Section
            Section(header: Text("About")) {
                Link(destination: URL(string: "https://github.com/lsongdev/picovpn-ios")!) {
                    HStack {
                        Text("GitHub")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                    }
                }
                
                Link(destination: URL(string: "https://xtls.github.io")!) {
                    HStack {
                        Text("Documentation")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("About")
        .listStyle(InsetGroupedListStyle())
    }
}
