//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//


import XCTest
@testable import AppSyncRealTimeClient

class URLSessionWebSocketAdapterTests: AppSyncRealTimeClientTestBase {

    func testConnectDisconnect() throws {
        let adapter = URLSessionWebSocketAdapter()
        let apiKeyAuthInterceptor = APIKeyAuthInterceptor(apiKey)
        let request = AppSyncConnectionRequest(url: urlRequest.url!)
        let signedRequest = apiKeyAuthInterceptor.interceptConnection(request, for: urlRequest.url!)
        urlRequest.url = signedRequest.url
        let expectedPerforms = expectation(description: "total performs")
        expectedPerforms.expectedFulfillmentCount = 1_000
        DispatchQueue.concurrentPerform(iterations: 1_000) { _ in
            adapter.connect(
                urlRequest: urlRequest,
                protocols: ["graphql-ws"],
                delegate: nil
            )
            adapter.disconnect()
            expectedPerforms.fulfill()
        }
        wait(for: [expectedPerforms], timeout: 1)
        XCTAssertFalse(adapter.isConnected)
    }

    func testDelegateInvocations() async {
        let adapter = URLSessionWebSocketAdapter()
        let apiKeyAuthInterceptor = APIKeyAuthInterceptor(apiKey)
        let request = AppSyncConnectionRequest(url: urlRequest.url!)
        let signedRequest = apiKeyAuthInterceptor.interceptConnection(request, for: urlRequest.url!)
        urlRequest.url = signedRequest.url
        let connectedException = expectation(description: "Connected")
        let disconnectedException = expectation(description: "Disconnected")

        adapter.connect(
            urlRequest: urlRequest,
            protocols: ["graphql-ws"],
            delegate: WebSocketDelegate(
                connectedException: connectedException,
                disconnectedException: disconnectedException
            )
        )

        await fulfillment(of: [connectedException], timeout: 3)

        adapter.disconnect()
        await fulfillment(of: [disconnectedException], timeout: 3)
    }

}


fileprivate class WebSocketDelegate: NSObject {

    private let connectedExpectation: XCTestExpectation

    private let disconnectedExpectation: XCTestExpectation


}

fileprivate extension WebSocketDelegate: AppSyncWebsocketDelegate {

    func websocketDidConnect(provider: AppSyncWebsocketProvider) {
        connectedExpectation.fulfill()
    }

    func websocketDidDisconnect(provider: AppSyncWebsocketProvider, error: Error?) {
        XCTAssertNotNil(error)
        disconnectedExpectation.fulfill()
    }
}
