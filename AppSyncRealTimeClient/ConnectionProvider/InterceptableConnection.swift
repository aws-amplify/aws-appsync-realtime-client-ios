//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Intercepts the connect request
public protocol ConnectionInterceptable {

    /// Add a new interceptor to the object.
    ///
    /// - Parameter interceptor: interceptor to be added
    func addInterceptor(_ interceptor: ConnectionInterceptor)

    func interceptConnection(_ request: AppSyncConnectionRequest, for endpoint: URL) -> AppSyncConnectionRequest
}

/// Intercepts the connect request
//@available(iOS 13.0.0, *)
public protocol ConnectionInterceptableAsync {

    /// Add a new interceptor to the object.
    ///
    /// - Parameter interceptor: interceptor to be added
    func addInterceptor(_ interceptor: ConnectionInterceptorAsync)

    func interceptConnection(_ request: AppSyncConnectionRequest, for endpoint: URL) async -> AppSyncConnectionRequest
}

public protocol MessageInterceptable {

    func addInterceptor(_ interceptor: MessageInterceptor)

    func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) -> AppSyncMessage
}

//@available(iOS 13.0.0, *)
public protocol MessageInterceptableAsync {

    func addInterceptor(_ interceptor: MessageInterceptorAsync)

    func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) async -> AppSyncMessage
}

public protocol ConnectionInterceptor {

    func interceptConnection(_ request: AppSyncConnectionRequest, for endpoint: URL) -> AppSyncConnectionRequest
}

//@available(iOS 13.0.0, *)
public protocol ConnectionInterceptorAsync {

    func interceptConnection(_ request: AppSyncConnectionRequest, for endpoint: URL) async -> AppSyncConnectionRequest
}

public protocol MessageInterceptor {

    func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) -> AppSyncMessage
}

//@available(iOS 13.0.0, *)
public protocol MessageInterceptorAsync {

    func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) async -> AppSyncMessage
}

public protocol AuthInterceptor: MessageInterceptor, ConnectionInterceptor {}

//@available(iOS 13.0.0, *)
public protocol AuthInterceptorAsync: MessageInterceptorAsync, ConnectionInterceptorAsync {}
