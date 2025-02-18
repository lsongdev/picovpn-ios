//
//  PolicyView.swift
//  PicoVPN
//
//  Created by Lsong on 2/14/25.
//
import SwiftUI

struct PolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var policy: Policy
    @State private var system: PolicySystem
    var onSave: (Policy) -> Void
    
    init(policy: Policy?, onSave: @escaping (Policy) -> Void) {
        self.onSave = onSave
        self.policy = policy ?? Policy()
        self.system = policy?.system ?? PolicySystem()
    }
    
    var body: some View {
        List {
            Section("System") {
                Toggle("statsInboundUplink", isOn: $system.statsInboundUplink)
                Toggle("statsInboundDownlink", isOn: $system.statsInboundDownlink)
                Toggle("statsOutboundUplink", isOn: $system.statsOutboundUplink)
                Toggle("statsOutboundDownlink", isOn: $system.statsOutboundDownlink)
            }
            
        }
        .navigationBarTitle("Policy", displayMode: .inline)
        .navigationBarItems(trailing: saveButton)
    }
    
    var saveButton: some View {
        Button("Save") {
            policy.system = system
            onSave(policy)
            dismiss()
        }
    }
    var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
}
