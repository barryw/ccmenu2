/*
 *  Copyright (c) Erik Doernenburg and contributors
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License.
 */

import SwiftUI


struct AppearanceSettings: View {

    @ObservedObject var settings: UserSettings

    var body: some View {
        Toggle(isOn: $settings.useColorInMenuBar) {
            Text("Use color in menu bar")
        }
            .frame(width: 300)
            .navigationTitle("Appearance")
            .padding(80)
    }

}


struct AppearanceSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettings(settings: settingsForPreview())
    }

    private static func settingsForPreview() -> UserSettings {
        let s = UserSettings()
        s.useColorInMenuBar = true
        return s
    }

}