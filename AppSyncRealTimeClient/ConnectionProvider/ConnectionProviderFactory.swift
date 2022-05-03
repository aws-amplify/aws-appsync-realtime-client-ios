//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Create connection providers to connect to the websocket endpoint of the AppSync endpoint.
public enum ConnectionProviderFactory {

    public static func createConnectionProvider(
        for url: URL,
        authInterceptor: AuthInterceptor,
        connectionType: SubscriptionConnectionType
    ) -> ConnectionProvider {
        let provider = ConnectionProviderFactory.createConnectionProvider(for: url, connectionType: connectionType)

        if let messageInterceptable = provider as? MessageInterceptable {
            messageInterceptable.addInterceptor(authInterceptor)
        }
        if let connectionInterceptable = provider as? ConnectionInterceptable {
            connectionInterceptable.addInterceptor(RealtimeGatewayURLInterceptor())
            connectionInterceptable.addInterceptor(authInterceptor)
        }

        return provider
    }

    @available(iOS 13.0.0, *)
    public static func createConnectionProvider(
        for url: URL,
        authInterceptor: AuthInterceptorAsync,
        connectionType: SubscriptionConnectionType
    ) -> ConnectionProvider {
        let provider = ConnectionProviderFactory.createConnectionProvider(
            for: url,
            connectionType: connectionType,
            asyncProvider: true
        )

        if let messageInterceptable = provider as? MessageInterceptableAsync {
            messageInterceptable.addInterceptor(authInterceptor)
        }
        if let connectionInterceptable = provider as? ConnectionInterceptableAsync {
            connectionInterceptable.addInterceptor(RealtimeGatewayURLInterceptor())
            connectionInterceptable.addInterceptor(authInterceptor)
        }

        return provider
    }

    static func createConnectionProvider(
        for url: URL,
        connectionType: SubscriptionConnectionType,
        asyncProvider: Bool = false
    ) -> ConnectionProvider {
        switch connectionType {
        case .appSyncRealtime:
            let websocketProvider = StarscreamAdapter()
            if asyncProvider {
                if #available(iOS 13.0, *) {
                    return RealtimeConnectionProviderAsync(for: url, websocket: websocketProvider)
                } else {
                    AppSyncLogger.error("Attempted to use an async provider with an iOS version < 13.0")
                    return RealtimeConnectionProvider(for: url, websocket: websocketProvider)
                }
            } else {
                return RealtimeConnectionProvider(for: url, websocket: websocketProvider)
            }
        }
    }
}
