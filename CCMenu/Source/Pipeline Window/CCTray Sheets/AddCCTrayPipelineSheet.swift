/*
 *  Copyright (c) Erik Doernenburg and contributors
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License.
 */

import SwiftUI

struct AddCCTrayPipelineSheet: View {
    @Binding var config: PipelineSheetConfig
    @Environment(\.presentationMode) @Binding var presentation
    @State var useBasicAuth = false
    @State var credential = HTTPCredential(user: "", password: "")
    @StateObject private var projectList = CCTrayProjectList()
    @StateObject private var builder = CCTrayPipelineBuilder()

    var body: some View {
        VStack {
            Text("Add project from CCTray feed")
                .font(.headline)
                .padding(.bottom)
            Text("Enter the URL of a CCTray feed, and press return to retrieve the project list. If you receive an error message try opening the URL in a web browser. If the browser doesn't show an XML document in [cctray format](https://cctray.org/v1/) then the feed URL is incorrect.")
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)

            CCTrayAuthView(useBasicAuth: $useBasicAuth, credential: $credential)
            .padding(.bottom)

            Form {
                TextField("Server:", text: $builder.feedUrl, prompt: Text("URL"))
                    .accessibilityIdentifier("Server URL field")
                    .autocorrectionDisabled(true)
                    .onSubmit {
                        if !builder.feedUrl.isEmpty {
                            Task { await projectList.updateProjects(url: $builder.feedUrl, credential: credentialOptional) }
                        }
                    }

                Picker("Project:", selection: $projectList.selected) {
                    ForEach(projectList.items) { p in
                        Text(p.name).tag(p)
                    }
                }
                .accessibilityIdentifier("Project picker")
                .disabled(!projectList.selected.isValid)
                .onChange(of: projectList.selected) { _ in
                    builder.project = projectList.selected
                }
                .padding(.bottom)

                HStack {
                    TextField("Display name:", text: $builder.name)
                        .accessibilityIdentifier("Display name field")
                    Button("Reset", systemImage: "arrowshape.turn.up.backward") {
                        builder.setDefaultName()
                    }
                }
                .padding(.bottom)
            }

            HStack {
                Button("Cancel") {
                    presentation.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("Apply") {
                    let p = builder.makePipeline(credential: credentialOptional)
                    config.setPipeline(p)
                    presentation.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!builder.canMakePipeline)
            }
        }
        .frame(minWidth: 400)
        .frame(idealWidth: 450)
        .padding()
    }

    private var credentialOptional: HTTPCredential? {
        (useBasicAuth && !credential.isEmpty) ? credential : nil
    }
    
}


struct AddCCTrayPipelineSheet_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            AddCCTrayPipelineSheet(model: PipelineModel())
        }
    }
}

