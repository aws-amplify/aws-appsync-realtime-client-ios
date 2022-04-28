//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

@available(iOS 13.0.0, *)
extension RealtimeConnectionProviderBase: MessageInterceptableAsync {
    public func addInterceptor(_ interceptor: MessageInterceptorAsync) {
        useAsyncInterceptors = true
        messageInterceptors.append(interceptor)
    }

    public func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) async -> AppSyncMessage {
        guard let messageInterceptors = messageInterceptors as? [MessageInterceptorAsync] else {
            AppSyncLogger.error("Failed to cast messageInterceptors.")
            return message
        }

        var finalMessage = message
        for interceptor in messageInterceptors {
            finalMessage = await interceptor.interceptMessage(finalMessage, for: endpoint)
        }

        return finalMessage
    }
}
