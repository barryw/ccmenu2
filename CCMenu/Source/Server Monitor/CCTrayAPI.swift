/*
 *  Copyright (c) Erik Doernenburg and contributors
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License.
 */

import Foundation

struct HTTPCredential {
    var user: String
    var password: String
    var bearerToken: String
    var authType: AuthorizationType

    var isEmpty: Bool {
        (authType == .none) || (authType == .basic && user.isEmpty && password.isEmpty) || (authType == .bearer && bearerToken.isEmpty)
    }
}

class CCTrayAPI {

    static func requestForProjects(url: URL, credential: HTTPCredential?) -> URLRequest {
        var request = URLRequest(url: url)

        if let credential {
            var v: String?
            
            switch credential.authType {
            case .none:
                break
            case .basic:
                v = URLRequest.basicAuthValue(user: credential.user, password: credential.password)
            case .bearer:
                v = URLRequest.bearerAuthValue(token: credential.bearerToken)
            }
            
            if let v {
                request.setValue(v, forHTTPHeaderField: "Authorization")
            }
        }

        return request
    }
}
