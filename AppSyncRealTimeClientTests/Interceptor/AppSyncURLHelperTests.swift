//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import AppSyncRealTimeClient

class AppSyncURLHelperTests: XCTestCase {

    /// Test if given graphql endpoint has standard appsync domain
    ///
    /// - Given: A graphql endpoint with standard appsync domain
    /// - When: I invoke AppSyncURLHelper.hasStandardAppsyncGraphQLDomain()
    /// - Then: It should return true
    func testURLStandardAppSyncDomain() {
        let standardDomainURL =
            URL(string: "https://abcdefghijklmnopqrstuvwxyz.appsync-api.us-west-2.amazonaws.com/graphql")!
        XCTAssertTrue(AppSyncURLHelper.isStandardAppSyncGraphQLEndpoint(url: standardDomainURL))
    }

    /// Test if given graphql endpoint in capital letters has standard appsync domain
    ///
    /// - Given: A graphql endpoint in capital letters with standard appsync domain
    /// - When: I invoke AppSyncURLHelper.hasStandardAppsyncGraphQLDomain()
    /// - Then: It should return true
    func testURLStandardAppSyncDomainCaseInsensitive() {
        let standardDomainURL =
            URL(string: "HTTPS://ABCDEFGHIJKLMNOPQRSTUVWXYZ.APPSYNC-API.US-WEST-2.AMAZONAWS.COM/GRAPHQL")!
        XCTAssertTrue(AppSyncURLHelper.isStandardAppSyncGraphQLEndpoint(url: standardDomainURL))
    }

    /// Test if given graphql endpoint has a custom domain
    ///
    /// - Given: A graphql endpoint with a custom domain
    /// - When: I invoke AppSyncURLHelper.hasStandardAppsyncGraphQLDomain()
    /// - Then: It should return false
    func testURLCustomAppSyncDomain() {
        let customDomainURL =
            URL(string: "https://api.example.com/graphql")!
        XCTAssertFalse(AppSyncURLHelper.isStandardAppSyncGraphQLEndpoint(url: customDomainURL))
    }
}
