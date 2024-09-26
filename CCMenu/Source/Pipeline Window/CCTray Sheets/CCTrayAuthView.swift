/*
 *  Copyright (c) Erik Doernenburg and contributors
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License.
 */


import SwiftUI

struct CCTrayAuthView: View {
    @Binding var credential: HTTPCredential
    
    var bearerToken: Binding<String> {
        Binding {
            credential.bearerToken ?? ""
        } set: {
            credential.bearerToken = $0
        }
    }
    
    var body: some View {
        VStack {
            GroupBox() {
                VStack(alignment: .leading) {
                    HStack {
                        Picker("Authentication", selection: $credential.authType) {
                            Text("None")
                                .tag(AuthorizationType.none)
                            Text("Basic")
                                .tag(AuthorizationType.basic)
                            Text("Bearer Token")
                                .tag(AuthorizationType.bearer)
                        }
                        .pickerStyle(.automatic)
                    }
                    switch credential.authType {
                    case .none:
                        Text("No authentication will be used")
                    case .basic:
                        Text("Authentication will be done with a username and password")
                        HStack {
                            TextField("", text: $credential.user, prompt: Text("user"))
                                .accessibilityIdentifier("User field")
                            SecureField("", text: $credential.password, prompt: Text("password"))
                                .accessibilityIdentifier("Password field")
                        }
                    case .bearer:
                        Text("Authentication will be done with a bearer token")
                        SecureField("", text: bearerToken, prompt: Text("bearer token"))
                            .accessibilityIdentifier("Bearer token field")
                    }
                    Spacer()
                }
                .padding(8)
            }
            .frame(minHeight: 105)
        }
    }
}

struct CCTrayAuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CCTrayAuthView(credential: .constant(HTTPCredential(user: "", password: "", bearerToken: "", authType: .none)))
        }.previewDisplayName("No Auth")
        Group {
            CCTrayAuthView(credential: .constant(HTTPCredential(user: "fred", password: "fredspassword", bearerToken: "", authType: .basic)))
        }.previewDisplayName("Basic Auth")
        Group {
            CCTrayAuthView(credential: .constant(HTTPCredential(user: "", password: "", bearerToken: "abc123", authType: .bearer)))
        }.previewDisplayName("Bearer Auth")
    }
}
