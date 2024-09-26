/*
 *  Copyright (c) Erik Doernenburg and contributors
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License.
 */

import Foundation

enum CCTrayFeedReaderError: LocalizedError {
    case invalidURLError
    case noProjectName
    case missingPasswordError
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURLError:
            return NSLocalizedString("invalid URL", comment: "")
        case .noProjectName:
            return NSLocalizedString("no project name in CCTray pipeline", comment: "")
        case .missingPasswordError:
            return NSLocalizedString("no matching password in Keychain", comment: "")
        case .httpError(let statusCode):
            return HTTPURLResponse.localizedString(forStatusCode: statusCode)
        }
    }
}


class CCTrayFeedReader {

    private(set) var pipelines: [Pipeline]

    init(for pipelines: [Pipeline]) {
        self.pipelines = pipelines
    }
    
    func updatePipelineStatus() async {
        do {
            // All pipelines have the same URL.
            let request = try requestForFeed(feed: pipelines[0].feed)
            #if DEBUG
            debugPrint(Date(), "fetching", request.url ?? "")
            #endif
            try await fetchStatus(request: request)
        } catch {
            for i in 0..<pipelines.count {
                pipelines[i].status = PipelineStatus(activity: .other)
                pipelines[i].connectionError = error.localizedDescription
            }
        }
    }

    func requestForFeed(feed: PipelineFeed) throws -> URLRequest {
        var credential: HTTPCredential?
        
        let authType = Keychain.standard.getAuthType(forURL: feed.url.absoluteString)
        switch authType {
        case .none:
            break
        case .basic:
            if let user = feed.url.user(percentEncoded: false) {
                guard let password = try Keychain.standard.getPassword(forURL: feed.url) else {
                    throw CCTrayFeedReaderError.missingPasswordError
                }
                credential = HTTPCredential(user: user, password: password, bearerToken: "", authType: .basic)
            }
        case .bearer:
            if let bearerToken = try Keychain.standard.getToken(forService: feed.url.absoluteString) {
                credential = HTTPCredential(user: "", password: "", bearerToken: bearerToken, authType: .bearer)
            }
        }
        
        return CCTrayAPI.requestForProjects(url: feed.url, credential: credential)
    }

    private func fetchStatus(request: URLRequest) async throws {
        let (data, response) = try await URLSession.feedSession.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw URLError(.unsupportedURL) }
        if response.statusCode != 200 {
            throw CCTrayFeedReaderError.httpError(response.statusCode)
        }
        let parser = CCTrayResponseParser()
        try parser.parseResponse(data)
        for p in self.pipelines {
            guard let name = p.feed.name else { throw CCTrayFeedReaderError.noProjectName }
            let status = parser.pipelineStatus(name: name)
            self.updatePipeline(name: p.name, newStatus: status)
        }
    }

    func updatePipeline(name: String, newStatus: PipelineStatus?) {
        guard let idx = pipelines.firstIndex(where: { p in p.name == name }) else { return }
        var pipeline = pipelines[idx]
        guard let newStatus else {
            pipeline.connectionError = "The server did not provide a status for this pipeline."
            pipelines[idx] = pipeline
            return
        }
        pipeline.connectionError = nil

        let oldStatus = pipeline.status
        pipeline.status = newStatus
        pipeline.status.currentBuild?.timestamp = oldStatus.currentBuild?.timestamp
        pipeline.status.lastBuild?.duration = oldStatus.lastBuild?.duration

        if oldStatus.activity != .building && newStatus.activity == .building {
            pipeline.status.currentBuild?.timestamp = Date.now
        }
        if oldStatus.activity == .building && newStatus.activity != .building {
            if let timestamp = oldStatus.currentBuild?.timestamp {
                pipeline.status.lastBuild?.duration = DateInterval(start: timestamp, end: Date.now).duration
            }
        }
        pipelines[idx] = pipeline
    }

}
