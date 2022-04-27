//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension RealtimeConnectionProvider: MessageInterceptable {

    public func addInterceptor(_ interceptor: MessageInterceptor) {
        messageInterceptors.append(interceptor)
    }

    public func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) -> AppSyncMessage {
        guard let messageInterceptors = messageInterceptors as? [MessageInterceptor] else {
            AppSyncLogger.error("Failed to cast messageInterceptors.")
            return message
        }

        let finalMessage = messageInterceptors.reduce(message) { $1.interceptMessage($0, for: endpoint) }
        return finalMessage
    }
}
