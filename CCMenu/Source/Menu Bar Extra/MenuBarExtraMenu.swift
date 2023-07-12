/*
 *  Copyright (c) Erik Doernenburg and contributors
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License.
 */

import SwiftUI


struct MenuBarExtraMenu: View {
    @ObservedObject var model: ViewModel
    @Environment(\.openWindow) var openWindow

    var body: some View {
        ForEach(model.pipelinesForMenu) { lp in
            Button() {
                WorkspaceController().openPipeline(lp.pipeline)
            } label: {
                Label(title: { Text(lp.label) }, icon: { Image(nsImage: lp.pipeline.statusImage) } )
                .labelStyle(.titleAndIcon)

            }
        }
        Divider()
        Button("Show Pipeline Window") {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "pipeline-list")
        }
        Button("Update Status of All Pipelines") {
            model.reloadPipelineStatus()
        }
        Divider()
        Button("About CCMenu") {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.sendAction(#selector(AppDelegate.orderFrontAboutPanelWithSourceVersion(_:)), to: nil, from: self)
        }
        Button("Settings...") {
            // If/when this stops working in Sonoma: https://stackoverflow.com/questions/65355696/how-to-programatically-open-settings-preferences-window-in-a-macos-swiftui-app
            NSApp.activate(ignoringOtherApps: true)
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        Divider()
        Button("Quit CCMenu") {
            NSApp.sendAction(#selector(NSApplication.terminate(_:)), to: nil, from: self)
        }
    }

}


struct MenuBarExtraContent_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) { // TODO: Can I render this as a menu somehow?
            MenuBarExtraMenu(model: viewModelForPreview())
        }
        .buttonStyle(.borderless)
        .padding(4)
        .frame(maxWidth: 300)
    }

    static func viewModelForPreview() -> ViewModel {
        let model = ViewModel(settings: settingsForPreview())

        var p0 = Pipeline(name: "connectfour", feedUrl: "http://localhost:4567/cctray.xml", activity: .building)
        p0.status.lastBuild = Build(result: .failure)
        p0.status.lastBuild!.timestamp = ISO8601DateFormatter().date(from: "2020-12-27T21:47:00Z")

        var p1 = Pipeline(name: "erikdoe/ccmenu", feedUrl: "https://api.travis-ci.org/repositories/erikdoe/ccmenu/cc.xml", activity: .sleeping)
        p1.status.lastBuild = Build(result: .success)
        p1.status.lastBuild!.timestamp = ISO8601DateFormatter().date(from: "2020-12-27T21:47:00Z")
        p1.status.lastBuild!.label = "build.151"

        model.pipelines = [p0, p1]

        model.update(pipeline: p0)
        model.update(pipeline: p1)

        return model
    }

    private static func settingsForPreview() -> UserSettings {
        let s = UserSettings()
        return s
    }

}