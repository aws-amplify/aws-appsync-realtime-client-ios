//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class AppSyncRealTimeClientTestBase: XCTestCase {

    var urlRequest: URLRequest!
    var apiKey: String!
    let requestString = """
        subscription onCreate {
          onCreateTodo{
            id
            description
            name
          }
        }
        """

    override func setUp() {
        AppSyncRealTimeClient.logLevel = .debug
        do {
            let json = try ConfigurationHelper.retrieve(forResource: "amplifyconfiguration")
            if let data = json as? [String: Any],
                let api = data["api"] as? [String: Any],
                let plugins = api["plugins"] as? [String: Any],
                let awsAPIPlugin = plugins["awsAPIPlugin"] as? [String: Any],
                let apiNameOptional = awsAPIPlugin.first,
                let apiName =  apiNameOptional.value as? [String: Any],
                let endpoint = apiName["endpoint"] as? String,
                let apiKey = apiName["apiKey"] as? String {

                urlRequest = URLRequest(url: URL(string: endpoint)!)

                self.apiKey = apiKey
            } else {
                throw "Could not retrieve endpoint"
            }

        } catch {
            print("Error \(error)")
        }
    }

}
