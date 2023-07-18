/*
 *  Copyright (c) Erik Doernenburg and contributors
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License.
 */

import SwiftUI


struct PipelineListToolbar: ToolbarContent {

    @ObservedObject var model: ViewModel
    @ObservedObject var viewState: PipelineListViewModel
    @Binding var selection: Set<String>
    @EnvironmentObject var settings: UserSettings

    var body: some ToolbarContent {
        ToolbarItemGroup {
            Menu() {
                Picker(selection: $settings.showStatusInPipelineWindow, label: EmptyView()) {
                    Text("Pipeline URL").tag(false)
                    Text("Build Status").tag(true)
                }
                .pickerStyle(InlinePickerStyle())
                .accessibility(label: Text("Details picker"))
                Button(settings.showMessagesInPipelineWindow ? "Hide Messages" : "Show Messages") {
                    settings.showMessagesInPipelineWindow.toggle()
                }
                .disabled(!settings.showStatusInPipelineWindow)
                Button(settings.showAvatarsInPipelineWindow ? "Hide Avatars" : "Show Avatars") {
                    settings.showAvatarsInPipelineWindow.toggle()
                }
                .disabled(!settings.showStatusInPipelineWindow)
            } label: {
                Image(systemName: "list.dash.header.rectangle")
            }
            .menuStyle(.borderlessButton)
            .accessibility(label: Text("Display detail menu"))
            .help("Select which details to show for the pipelines")

            Spacer() // TODO: This shouldn't be necessary
        }

        ToolbarItemGroup {
            Menu() {
                Button("Add project from CCTray feed...") {
                    viewState.editIndex = nil
                    viewState.sheetType = .cctray
                    viewState.isShowingSheet = true
                }
                Button("Add Github workflow...") {
                    viewState.editIndex = nil
                    viewState.sheetType = .github
                    viewState.isShowingSheet = true
                }
            } label: {
                Image(systemName: "plus.square")
            }
            .menuStyle(.borderlessButton)
            .accessibility(label: Text("Add pipeline menu"))
            .help("Add a pipeline")

            Button() {
                viewState.editIndex = selectionIndexSet().first
                viewState.isShowingSheet = true
            } label: {
                Label("Edit", systemImage: "gearshape")
            }
            .help("Edit pipeline")
            .accessibility(label: Text("Edit pipeline"))
            .disabled(selection.count != 1)

            Button() {
                withAnimation {
                    model.pipelines.remove(atOffsets: selectionIndexSet())
                    selection.removeAll()
                }
            } label: {
                Label("Remove", systemImage: "trash")
            }
            .help("Remove pipeline")
            .accessibility(label: Text("Remove pipeline"))
            .disabled(selection.isEmpty)
        }

        ToolbarItemGroup {
            Button() {
                model.reloadPipelineStatus()
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
            }
            .help("Update status of all pipelines")
        }
    }

    private func selectionIndexSet() -> IndexSet {
        var indexSet = IndexSet()
        for (i, p) in model.pipelines.enumerated() {
            if selection.contains(p.id) {
                indexSet.insert(i)
            }
        }
        return indexSet
    }

}
