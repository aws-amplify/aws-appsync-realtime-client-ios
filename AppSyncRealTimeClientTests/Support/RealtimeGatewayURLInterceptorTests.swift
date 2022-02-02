//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class RealtimeGatewayURLInterceptorTests: XCTestCase {

    var realtimeGatewayURLInterceptor: RealtimeGatewayURLInterceptor!

    override func setUp() {
        realtimeGatewayURLInterceptor = RealtimeGatewayURLInterceptor()
    }

    func testStandardDomainInterceptRequest() {
        let url = URL(string: "https://abcdefghijklmnopqrstuvwxyz.appsync-api.us-west-2.amazonaws.com/graphql")!
        let request = AppSyncConnectionRequest(url: url)
        let changedRequest = realtimeGatewayURLInterceptor.interceptConnection(request, for: url)
        XCTAssertEqual(changedRequest.url.scheme, "wss", "Scheme should be wss")
        XCTAssertEqual(
            changedRequest.url.absoluteString,
            "wss://abcdefghijklmnopqrstuvwxyz.appsync-realtime-api.us-west-2.amazonaws.com/graphql",
            "URL string should be wss://abcdefghijklmnopqrstuvwxyz.appsync-realtime-api.us-west-2.amazonaws.com/graphql"
        )
    }

    func testCustomDomainInterceptRequest() {
        let url = URL(string: "https://api.example.com/graphql")!
        let request = AppSyncConnectionRequest(url: url)
        let changedRequest = realtimeGatewayURLInterceptor.interceptConnection(request, for: url)
        XCTAssertEqual(changedRequest.url.scheme, "wss", "Scheme should be wss")
        XCTAssertEqual(
            changedRequest.url.absoluteString,
            "wss://api.example.com/graphql/realtime",
            "URL string should be wss://api.example.com/graphql/realtime"
        )
    }

}
