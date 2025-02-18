////
////  PicoWidgetControl.swift
////  PicoWidget
////
////  Created by Lsong on 2/21/25.
////
//
//import AppIntents
//import SwiftUI
//import WidgetKit
//
//struct PicoWidgetControl: ControlWidget {
//    static let kind: String = "me.lsong.picovpn.widget"
//
//    var body: some ControlWidgetConfiguration {
//        AppIntentControlConfiguration(
//            kind: Self.kind,
//            provider: Provider()
//        ) { value in
//            ControlWidgetToggle(
//                "Start VPN",
//                isOn: value.isRunning,
//                action: StartTimerIntent(value.name)
//            ) { isRunning in
//                Image(systemName: "bolt.circle.fill")
//                    .foregroundColor(.white)
//                    .background(.white)
//            }
//        }
//        .displayName("Start VPN")
//        .description("A an example control that run picovpn.")
//    }
//}
//
//extension PicoWidgetControl {
//    struct Value {
//        var isRunning: Bool
//        var name: String
//    }
//
//    struct Provider: AppIntentControlValueProvider {
//        func previewValue(configuration: TimerConfiguration) -> Value {
//            PicoWidgetControl.Value(isRunning: false, name: configuration.timerName)
//        }
//
//        func currentValue(configuration: TimerConfiguration) async throws -> Value {
//            let isRunning = true // Check if the timer is running
//            return PicoWidgetControl.Value(isRunning: isRunning, name: configuration.timerName)
//        }
//    }
//}
//
//struct TimerConfiguration: ControlConfigurationIntent {
//    static let title: LocalizedStringResource = "Timer Name Configuration"
//
//    @Parameter(title: "Timer Name", default: "Timer")
//    var timerName: String
//}
//
//struct StartTimerIntent: SetValueIntent {
//    static let title: LocalizedStringResource = "Start a timer"
//
//    @Parameter(title: "Timer Name")
//    var name: String
//
//    @Parameter(title: "Timer is running")
//    var value: Bool
//
//    init() {}
//
//    init(_ name: String) {
//        self.name = name
//    }
//
//    func perform() async throws -> some IntentResult {
//        // Start the timer…
//        return .result()
//    }
//}
