import NetworkExtension
import Network
import Tun2SocksKit
import Xray
import os

class PacketTunnelProvider: NEPacketTunnelProvider {
    let defaults = UserDefaults(suiteName: Common.groupName)!
    
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        let port = defaults.integer(forKey: "port") as NSNumber
        os_log("Starting Socks5 tunnel with options: %{public}@", String(describing: options))
        // Set up the tunnel configuration
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        networkSettings.mtu = 9000
        
        // Configure IPv4 settings
        let ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.2"], subnetMasks: ["255.255.255.0"])
        // ipv4Settings.excludedRoutes = [NEIPv4Route(destinationAddress: "0.0.0.0", subnetMask: "255.0.0.0")]
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings
        
        let ipv6Settings = NEIPv6Settings(addresses: ["fd6e:a81b:704f:1211::1"], networkPrefixLengths: [64])
        // ipv6Settings.excludedRoutes = [NEIPv6Route(destinationAddress: "::", networkPrefixLength: 64)]
        ipv6Settings.includedRoutes = [NEIPv6Route.default()]
        networkSettings.ipv6Settings = ipv6Settings
        
        // Configure DNS settings
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "114.114.114.114"])
        dnsSettings.matchDomains = [""]
        networkSettings.dnsSettings = dnsSettings
    
        // Apply the network settings
        try await self.setTunnelNetworkSettings(networkSettings)
        os_log("Network settings applied successfully")
        try startXray()
        try startSocks5Tunnel(host: "127.0.0.1", port: port)
    }
    
    private func startXray() throws {
        XraySetEnv("xray.location.asset", Common.datasetsPath.path)
        XrayStart(Common.configPath.path)
    }
    private func startSocks5Tunnel(host: NSString, port: NSNumber) throws {
        let config = """
        tunnel:
          mtu: 9000
        socks5:
          udp: 'udp'
          port: \(port)
          address: \(host)
          # username: ''
          # password: ''
          # mark: 0
          # pipeline: false
        misc:
          task-stack-size: 20480
          connect-timeout: 5000
          read-write-timeout: 60000
          log-file: stderr
          log-level: error
          limit-nofile: 65535
        """
        Socks5Tunnel.run(withConfig: .string(content: config)) { code in
            os_log("Socks5 tunnel started with exit code: \(code)")
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Stopping Socks5 tunnel with reason: \(reason.rawValue)")
        Socks5Tunnel.quit()
        XrayStop()
        setTunnelNetworkSettings(nil) { error in
            if let error = error {
                os_log("Failed to clear network settings: \(error.localizedDescription)")
            }
            completionHandler()
        }
    }
}

