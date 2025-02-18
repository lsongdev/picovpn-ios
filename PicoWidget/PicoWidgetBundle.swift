//
//  PicoWidgetBundle.swift
//  PicoWidget
//
//  Created by Lsong on 2/21/25.
//

import WidgetKit
import SwiftUI

@main
struct PicoWidgetBundle: WidgetBundle {
    var body: some Widget {
        PicoWidget()
//        PicoWidgetControl()
        PicoWidgetLiveActivity()
    }
}
