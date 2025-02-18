//
//  BalancerView.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//
import SwiftUI
import SwiftUIX

struct BalancerView: View {
    @Environment(\.dismiss) var dismiss
    @State var balancer: Balancer = Balancer()
    @State private var newSelector: String = ""
    
    var proxies: [Outbound] = []
    var onSave: ((Balancer) -> Void)
    
    var body: some View {
        NavigationView {
            Form {
                InputField("Name", text: $balancer.tag)
                
                Section(header: Text("Selector")) {
                    ForEach(balancer.selector, id: \.self) { selector in
                        Text(selector)
                    }
                    .onDelete(perform: deleteSelector)
                    
                    HStack {
                        TextField("Add Selector", text: $newSelector)
                        Button {
                            if newSelector.isEmpty { return }
                            balancer.selector.append(newSelector)
                            newSelector = ""
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                
                Section {
                    Picker("Strategy", selection: $balancer.strategy.type) {
                        Text("<empty>").tag("")
                        Text("random").tag("random")
                        Text("roundRobin").tag("roundRobin")
                        Text("leastPing").tag("leastPing")
                        Text("leastLoad").tag("leastLoad")
                    }
                }
                
                Section {
                    Picker("Fallback Tag", selection: $balancer.fallbackTag) {
                        Text("<empty>").tag("")
                        ForEach(proxies.indices, id: \.self) { index in
                            Text(proxies[index].tag).tag(proxies[index].tag)
                        }
                    }
                }
                if balancer.strategy.type == "leastLoad" {
                    
                }
            }
            .navigationBarTitle(navigationBarTitle, displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
    var navigationBarTitle: String {
        if balancer.tag.isEmpty {
            return "Add Balancer"
        }
        return balancer.tag
    }
    func deleteSelector(idx: IndexSet) {
        
    }
    private var saveButton: some View {
        Button("Save") {
            onSave(balancer)
            dismiss()
        }
        .disabled(balancer.tag.isEmpty)
    }
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
}
