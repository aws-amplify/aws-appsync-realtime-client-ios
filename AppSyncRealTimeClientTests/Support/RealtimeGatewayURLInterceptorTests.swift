//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
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

    func testInterceptRequest() {
        let url = URL(string: "https://xxxxxxxxxxxxxxxxxxxxxxxxxx.appsync-api.us-west-2.amazonaws.com/graphql")!
        let request = AppSyncConnectionRequest(url: url)
        let changedRequest = realtimeGatewayURLInterceptor.interceptConnection(request, for: url)
        XCTAssertEqual(changedRequest.url.scheme, "wss", "Scheme should be wss")
        XCTAssertTrue(
            changedRequest.url.absoluteString.contains("appsync-realtime-api"),
            "URL should contain the realtime part"
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
            "URL string should be equal wss://api.example.com/graphql/realtime")
    }

}
