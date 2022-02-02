//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

class ConfigurationHelper {
    static func retrieve(forResource: String) throws -> Any {
        guard let path = Bundle.main.path(forResource: forResource, ofType: "json") else {
            throw "Could not retrieve configuration file: \(forResource)"
        }

        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data)
        return json
    }
}
