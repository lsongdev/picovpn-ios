//
//  PicoWidgetLiveActivity.swift
//  PicoWidget
//
//  Created by Lsong on 2/21/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PicoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PicoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PicoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PicoWidgetAttributes {
    fileprivate static var preview: PicoWidgetAttributes {
        PicoWidgetAttributes(name: "World")
    }
}

extension PicoWidgetAttributes.ContentState {
    fileprivate static var smiley: PicoWidgetAttributes.ContentState {
        PicoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PicoWidgetAttributes.ContentState {
         PicoWidgetAttributes.ContentState(emoji: "🤩")
     }
}
