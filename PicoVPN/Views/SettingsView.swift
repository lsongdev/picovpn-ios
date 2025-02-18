//
//  SettingsView.swift
//  PicoVPN
//
//  Created by Lsong on 1/23/25.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appManager: PicoAppManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: GeneralView()) {
                    Text("General")
                }
                NavigationLink(destination: NetworkSettingsView()) {
                    Text("Network")
                }
                NavigationLink(destination: DatasetsView()) {
                    Text("Datasets")
                }

                NavigationLink(destination: LogView()) {
                    Text("Logs")
                }
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}
