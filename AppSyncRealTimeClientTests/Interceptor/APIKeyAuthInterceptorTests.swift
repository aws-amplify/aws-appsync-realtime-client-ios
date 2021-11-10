//
// Copyright 2018-2021 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import AppSyncRealTimeClient

class APIKeyAuthInterceptorTests: XCTestCase {

    var apiKeyAuthInterceptor: APIKeyAuthInterceptor!

    override func setUp() {
        apiKeyAuthInterceptor = APIKeyAuthInterceptor("mock_api_key")
    }

    func testInterceptRequest() {
        let url = URL(string: "http://xxxc.appsync-api.ap-southeast-2.amazonaws.com/sd")!
        let request = AppSyncConnectionRequest(url: url)
        let signedRequest = apiKeyAuthInterceptor.interceptConnection(request, for: url)

        guard let queries = URLComponents(url: signedRequest.url, resolvingAgainstBaseURL: true)?.queryItems else {
            assertionFailure("Query parameters should not be nil")
            return
        }
        XCTAssertTrue(queries.contains { $0.name == "header"}, "Should contain the header query")
        XCTAssertTrue(queries.contains { $0.name == "payload"}, "Should contain the payload query")
    }

    func testInterceptMessage() {
        let message = AppSyncMessage(type: .subscribe("start"))
        let url = URL(string: "http://xxxc.appsync-api.ap-southeast-2.amazonaws.com/sd")!
        let signedMessage = apiKeyAuthInterceptor.interceptMessage(message, for: url)
        XCTAssertNotNil(signedMessage.payload?.authHeader)

    }
}
