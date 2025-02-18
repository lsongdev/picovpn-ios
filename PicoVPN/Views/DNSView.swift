//
//  DNSView.swift
//  PicoVPN
//
//  Created by Lsong on 2/6/25.
//

import SwiftUI
import SwiftUIX

var queryStrategies: [String] = ["UseIP", "UseIPv4", "UseIPv6"]

struct DNSView: View {
    @Environment(\.dismiss) var dismiss
    @State var dns: DNS = DNS()
    @State private var newServer: String = ""
    @State private var domain: String = ""
    @State private var ip: String = ""
    @State private var showingHost: Bool = false
    @State private var showingServer: Bool = false
    
    var onSave: ((DNS) -> Void)?
    
    init(dns: DNS?, onSave: ((DNS) -> Void)?){
        _dns = State(initialValue: dns ?? DNS())
        self.onSave = onSave
    }
    
    var body: some View {
        Form {
            
            Section {
                InputField("Name", text: $dns.tag, placeholder: "dns tag")
            }
            
            Picker("Query Strategy", selection: $dns.queryStrategy) {
                Text("<empty>").tag("")
                ForEach(queryStrategies, id: \.self) { strategy in
                    Text(strategy).tag(strategy)
                }
            }
            
            Section(header: HStack {
                Text("Servers")
                Spacer()
                Button (action: { showingServer = true }) {
                    Image(systemName: "plus")
                }
            }){
                ForEach(dns.servers.indices, id: \.self) { index in
                    Group {
                        switch dns.servers[index] {
                            case .simple(let server):
                            Text(server)
                        case .full(let server):
                            VStack (alignment: .leading) {
                                Text(server.address)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteServer)
                HStack {
                    TextField("dns server, eg.: 1.1.1.1", text: $newServer)
                    Button {
                        if !newServer.isEmpty {
                            dns.servers.append(DNSServerType.simple(newServer))
                            newServer = ""
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            
            Section(header: HStack {
                Text("Hosts")
                Spacer()
                Button (action: { showingHost = true }) {
                    Image(systemName: "plus")
                }
            }){
                ForEach(Array(dns.hosts.sorted(by: { $0.key < $1.key })), id: \.key) { domain, host in
                    VStack (alignment: .leading) {
                        Text(domain)
                        Text("\(String(describing: host))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete { index in
                    print("delete dns host \(index)")
                }
            }
            
        }
        .sheet(isPresented: $showingServer) {
            AddServerView(
                onSave: { server in
                    dns.servers.append(DNSServerType.full(server))
                }
            )
        }
        .sheet(isPresented: $showingHost) {
            AddHostView(
                onSave: { domain, host in
                    dns.hosts[domain] = host
                }
            )
        }
        .navigationTitle("DNS")
        .navigationBarItems(trailing: saveButton)
    }
    var saveButton: some View {
        Button("Save"){
            onSave?(dns)
            dismiss()
        }
    }
    private func deleteServer(at offsets: IndexSet) {
        dns.servers.remove(atOffsets: offsets)
    }
}

struct AddServerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var server = DNSServer()
    @State private var newDomain: String = ""
    
    var onSave: (DNSServer) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                InputField("Address", text: $server.address, placeholder: "1.2.3.4")
                InputField("Port", value: $server.port, placeholder: "53")
                
                Section("domains") {
                    ForEach(server.domains, id: \.self) { domain in
                        Text(domain)
                    }
                    HStack {
                        TextField("domain", text: $newDomain)
                        Spacer()
                        Button {
                            if newDomain.isEmpty { return }
                            server.domains.append(newDomain)
                            self.newDomain = ""
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            .navigationBarTitle("Add DNS Server", displayMode: .inline)
        }
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    var saveButton: some View {
        Button("Save") {
            onSave(server)
            dismiss()
        }
        .disabled(server.address.isEmpty)
    }
}

struct AddHostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var domain: String = ""
    @State private var hosts: [String] = []
    @State private var newIP: String = ""
    
    var onSave: (String, HostMapping) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                InputField("Domain", text: $domain, placeholder: "example.com")
                
                Section(header: Text("Address")) {
                    List {
                        ForEach(hosts, id: \.self) { ip in
                            Text(ip)
                        }
                        HStack {
                            TextField("1.2.3.4", text: $newIP)
                            Spacer()
                            Button {
                                if newIP.isEmpty { return }
                                self.hosts.append(newIP)
                                newIP = ""
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                        }
                    }
                }
            }
            
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            .navigationBarTitle("Add Host Mapping", displayMode: .inline)
        }
        
        
    }
    var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    var saveButton: some View {
        Button("Save") {
            if hosts.count > 1 {
                onSave(domain, HostMapping.multiple(hosts))
            } else {
                onSave(domain, HostMapping.direct(hosts.first!))
            }
            dismiss()
        }
        .disabled(hosts.count == 0)
    }
}
