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

    public func interceptMessage(
        _ message: AppSyncMessage,
        for endpoint: URL,
        completion: @escaping (AppSyncMessage) -> Void
    ) {

        chainInterceptors(
            index: 0,
            message: message,
            endpoint: endpoint,
            completion: completion
        )
    }

    private func chainInterceptors(
        index: Int,
        message: AppSyncMessage,
        endpoint: URL,
        completion: @escaping (AppSyncMessage) -> Void
    ) {

        guard index < messageInterceptors.count else {
            completion(message)
            return
        }
        let interceptor = messageInterceptors[index]
        interceptor.interceptMessage(message, for: endpoint) { interceptedMessage in
            self.chainInterceptors(
                index: index + 1,
                message: interceptedMessage,
                endpoint: endpoint,
                completion: completion
            )
        }
    }

    // MARK: Deprecated method

    public func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) -> AppSyncMessage {
        // This is added here for backward compatibility
        let finalMessage = messageInterceptors.reduce(message) { $1.interceptMessage($0, for: endpoint) }
        return finalMessage
    }
}
