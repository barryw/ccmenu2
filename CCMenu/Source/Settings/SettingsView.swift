/*
 *  Copyright (c) Erik Doernenburg and contributors
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License.
 */

import SwiftUI

struct SettingsView: View {
    
    private enum Tab: Hashable {
        case notifications
        case appearance
        case advanced
    }

    @ObservedObject var settings: UserSettings
    @State private var selectedTab: Tab = .appearance
    
    var body: some View {
        // TODO: why does the animation not work?
        TabView(selection: $selectedTab.animation()) {
            NotificationSettings()
                .tag(Tab.notifications)
                .tabItem {
                    Image(systemName: "bell.badge")
                    Text("Notifications")
                }
            AppearanceSettings(settings: settings)
                .tag(Tab.appearance)
                .tabItem {
                    Image(systemName: "filemenu.and.selection")
                    Text("Appearance")
                }
            AdvancedSettings()
                .tag(Tab.advanced)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Advanced")
                }
            }
        }
}