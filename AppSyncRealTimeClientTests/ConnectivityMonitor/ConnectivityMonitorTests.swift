//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient
import Network

class ConnectivityMonitorTests: XCTestCase {

    /// Test `NetworkMonitor` that uses `NWPathMonitor`
    /// Only assert that the connectivity update isn't `nil` since the status is based on the conditions
    /// of when test is run.
    func testNetworkMonitor() {
        let connectivityUpdateReceived = expectation(description: "connectivity update received")
        let monitor = ConnectivityMonitor(monitor: nil)
        monitor.start { connectivity in
            connectivityUpdateReceived.fulfill()
            XCTAssertNotNil(connectivity)
        }
        wait(for: [connectivityUpdateReceived], timeout: 1)
        monitor.cancel()
    }

    func testMockConnectivityMonitor() {
        let mockMonitor = MockConnectivityMonitor()
        let monitor = ConnectivityMonitor(monitor: mockMonitor)
        let connectivityUpdateReceived = expectation(description: "connectivity update received")
        connectivityUpdateReceived.expectedFulfillmentCount = 3
        monitor.start { updates in
            XCTAssertNotNil(updates)
            connectivityUpdateReceived.fulfill()
        }
        mockMonitor.sendConnectivityUpdate(.init())
        mockMonitor.sendConnectivityUpdate(.init())
        mockMonitor.sendConnectivityUpdate(.init())
        wait(for: [connectivityUpdateReceived], timeout: 1)
        monitor.cancel()
    }
}
