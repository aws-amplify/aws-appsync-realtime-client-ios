//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

@available(iOS 13.0.0, *)
public protocol ConnectionProviderAsync: AnyObject {

    func connect() async

    func write(_ message: AppSyncMessage) async

    func disconnect() async

    func addListener(identifier: String, callback: @escaping ConnectionProviderCallbackAsync) async

    func removeListener(identifier: String) async
}

public typealias ConnectionProviderCallbackAsync = (ConnectionProviderEvent) async -> Void
