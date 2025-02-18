//
//  AppearanceSettingsView.swift
//  PicoVPN
//
//  Created by Lsong on 2/7/25.
//
import SwiftUI

enum ColorSchemeMode: String, CaseIterable {
    case system = "system"
    case dark = "dark"
    case light = "light"
    
    func getColorScheme() -> ColorScheme? {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return nil
        }
    }
}


enum AppTintColor: String, CaseIterable {
    case monochrome, blue, brown, gray, green, indigo, mint, orange, pink, purple, red, teal, yellow
    
    func getColor() -> Color {
        switch self {
        case .monochrome:
            .primary
        case .blue:
            .blue
        case .red:
            .red
        case .green:
            .green
        case .yellow:
            .yellow
        case .brown:
            .brown
        case .gray:
            .gray
        case .indigo:
            .indigo
        case .mint:
            .mint
        case .orange:
            .orange
        case .pink:
            .pink
        case .purple:
            .purple
        case .teal:
            .teal
        }
    }
}

enum AppFontDesign: String, CaseIterable {
    case standard, monospaced, rounded, serif
    
    func getFontDesign() -> Font.Design {
        switch self {
        case .standard:
            .default
        case .monospaced:
            .monospaced
        case .rounded:
            .rounded
        case .serif:
            .serif
        }
    }
}

enum AppFontWidth: String, CaseIterable {
    case compressed, condensed, expanded, standard
    
    func getFontWidth() -> Font.Width {
        switch self {
        case .compressed:
            .compressed
        case .condensed:
            .condensed
        case .expanded:
            .expanded
        case .standard:
            .standard
        }
    }
}

enum AppFontSize: String, CaseIterable {
    case xsmall, small, medium, large, xlarge
    
    func getFontSize() -> DynamicTypeSize {
        switch self {
        case .xsmall:
            .xSmall
        case .small:
            .small
        case .medium:
            .medium
        case .large:
            .large
        case .xlarge:
            .xLarge
        }
    }
}

struct GeneralView: View {
    @EnvironmentObject var appManager: PicoAppManager

    var body: some View {
        Form {
            
            Section {
                Picker(selection: $appManager.colorSchemeMode) {
                    ForEach(ColorSchemeMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                } label: {
                    Label("mode", systemImage: "moon")
                }
                Picker(selection: $appManager.appTintColor) {
                    ForEach(AppTintColor.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.rawValue) { option in
                        Text(String(describing: option).lowercased())
                            .tag(option)
                    }
                } label: {
                    Label("color", systemImage: "paintbrush.pointed")
                }
            }

            Section(header: Text("font")) {
                Picker(selection: $appManager.appFontDesign) {
                    ForEach(AppFontDesign.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.rawValue) { option in
                        Text(String(describing: option).lowercased())
                            .tag(option)
                    }
                } label: {
                    Label("design", systemImage: "textformat")
                }

                Picker(selection: $appManager.appFontWidth) {
                    ForEach(AppFontWidth.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.rawValue) { option in
                        Text(String(describing: option).lowercased())
                            .tag(option)
                    }
                } label: {
                    Label("width", systemImage: "arrow.left.and.line.vertical.and.arrow.right")
                }
                .disabled(appManager.appFontDesign != .standard)

                #if !os(macOS)
                Picker(selection: $appManager.appFontSize) {
                    ForEach(AppFontSize.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.rawValue) { option in
                        Text(String(describing: option).lowercased())
                            .tag(option)
                    }
                } label: {
                    Label("size", systemImage: "arrow.up.left.and.arrow.down.right")
                }
                #endif
            }
        }
        .formStyle(.grouped)
        .navigationBarTitle("General", displayMode: .inline)
    }
}
