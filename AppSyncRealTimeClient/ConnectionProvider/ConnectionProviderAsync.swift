//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol ConnectionProviderAsync: AnyObject {

    func connect()

    func write(_ message: AppSyncMessage)

    func disconnect()

    func addListener(identifier: String, callback: @escaping ConnectionProviderCallback)

    func removeListener(identifier: String)
}
