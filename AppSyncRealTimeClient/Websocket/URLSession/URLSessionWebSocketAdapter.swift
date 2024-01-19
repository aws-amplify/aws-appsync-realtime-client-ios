//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Combine

public class URLSessionWebSocketAdapter: NSObject {
    private weak var delegate: AppSyncWebsocketDelegate?
    public private(set) var isConnected: Bool

    private var webSocket: URLSessionWebSocketTask?
    private var receiveMessageTask: AnyCancellable?

    #if os(watchOS)
    private var connectivityTimer: AnyCancellable?
    #endif

    override init() {
        self.isConnected = false
    }

    deinit {
#if os(watchOS)
        connectivityTimer?.cancel()
#endif
        receiveMessageTask?.cancel()
        disconnect()
    }
}

extension URLSessionWebSocketAdapter: AppSyncWebsocketProvider {
    public func disconnect() {
        AppSyncLogger.verbose("[URLSessionWebSocketAdapter] Disconnecting websocket")
        webSocket?.cancel(with: .goingAway, reason: nil)
    }

    public func write(message: String) {
        guard isConnected else {
            AppSyncLogger.verbose(
                "[URLSessionWebSocketAdapter] Websocket is already disconnected, cannot send message: \(message)"
            )
            return
        }

        webSocket?.send(.string(message), completionHandler: { error in
            if let error = error {
                AppSyncLogger.warn(
                    "[URLSessionWebSocketAdapter] Failed to send websocket message with error \(error)"
                )
            }
        })
    }

    public func connect(urlRequest: URLRequest, protocols: [String], delegate: AppSyncWebsocketDelegate?) {
        self.delegate = delegate

        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        webSocket = session.webSocketTask(
            with: urlRequestWithWebsocketProtocols(urlRequest: urlRequest, protocols: protocols)
        )
        AppSyncLogger.verbose("[URLSessionWebSocketAdapter] Connecting...")
        webSocket?.resume()
    }

    private func urlRequestWithWebsocketProtocols(urlRequest: URLRequest, protocols: [String]) -> URLRequest {
        var request = urlRequest
        request.addValue(protocols.joined(separator: ","), forHTTPHeaderField: "Sec-WebSocket-Protocol")
        return request
    }

    #if os(watchOS)
    private func startConnectivityTimer() -> AnyCancellable {
        Timer.publish(every: 5, on: .current, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.global())
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                if !self.isConnected {
                    self.delegate?.websocketDidDisconnect(
                        provider: self,
                        error: ConnectionProviderError.connection
                    )
                }
            }
    }
    #endif

    private func startReceiveMessage() -> AnyPublisher<Void, Never> {
        return receiveMessage().flatMap { [weak self] in
            self?.startReceiveMessage() ?? Just(()).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    private func receiveMessage() -> Future<Void, Never> {
        Future() { [weak self] promise in
            guard let self = self else { return }

            self.webSocket?.receive(completionHandler: { result in
                switch result {
                case .success(.string(let string)):
                    AppSyncLogger.verbose("[URLSessionWebSocketAdapter] Received message: \(string)")
                    if let data = string.data(using: .utf8) {
                        self.delegate?.websocketDidReceiveData(provider: self, data: data)
                    }
                case .success(.data(let data)):
                    AppSyncLogger.verbose(
                        "[URLSessionWebSocketAdapter] Received message: \(String(describing: String(data: data, encoding: .utf8)))"
                    )
                    self.delegate?.websocketDidReceiveData(provider: self, data: data)

                case .failure(let error):
                    AppSyncLogger.warn("[URLSessionWebSocketAdapter] Received message, error \(error)")
                    self.delegate?.websocketDidReceiveError(provider: self, error: error)

                @unknown default:
                    break
                }
                promise(.success(()))
            })
        }
    }

}

extension URLSessionWebSocketAdapter: URLSessionDataDelegate {
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error = error {
            AppSyncLogger.warn("[URLSessionWebSocketAdapter] URLSession complete with error \(error)")
            delegate?.websocketDidReceiveError(provider: self, error: error)
        }
    }
}

extension URLSessionWebSocketAdapter: URLSessionWebSocketDelegate {
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        AppSyncLogger.verbose("[URLSessionWebSocketAdapter] Websocket connected")
        isConnected = true
        #if os(watchOS)
        if connectivityTimer != nil {
            connectivityTimer?.cancel()
        }
        connectivityTimer = startConnectivityTimer()
        #endif
        receiveMessageTask = startReceiveMessage().sink { }
        delegate?.websocketDidConnect(provider: self)
    }

    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        isConnected = false
        receiveMessageTask?.cancel()

        let message = reason.flatMap { String(data: $0, encoding: .utf8) }
        AppSyncLogger.verbose(
            "[URLSessionWebSocketAdapter] Websocket disconnected, reason \(String(describing: message)), code: \(closeCode)"
        )
        delegate?.websocketDidDisconnect(
            provider: self,
            error: ConnectionProviderError.unknown(message: message, causedBy: nil, payload: nil)
        )
    }
}
