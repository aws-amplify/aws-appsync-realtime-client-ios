//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Starscream

extension AppSyncSubscriptionConnection {
    func handleError(error: Error) {
        guard let subscriptionItem = subscriptionItem else {
            AppSyncLogger.warn("[AppSyncSubscriptionConnection] \(#function): missing subscription item")
            return
        }

        // If the error identifier is not for the this subscription
        // we return immediately without handling the error.
        if case let ConnectionProviderError.subscription(identifier, _) = error,
            identifier != subscriptionItem.identifier {
            return
        }
        
        if case let ConnectionProviderError.limitExceeded(identifier) = error {
            // We do not know which subscription this is for, either ignore it or send the error back
            // Don't go pass this check since it's not retryable, return from here
            if identifier == nil {
                // if we are subscribed already, then ignore it.
                if subscriptionState == .subscribed {
                    return
                } else {
                    // If we are .inProgress or .notSubscribed, set it to `.notSubscribed`, send the error back.
                    subscriptionState = .notSubscribed
                    if !throttled {
                        // TODO: we sent this back for this subscription, but we still don't really know which
                        // subscription was the one that was throttled.
                        subscriptionItem.subscriptionEventHandler(.failed(error), subscriptionItem)
                    }
                    
                    // Once we've sent it once, circuit break here using some state on the subscription.
                    throttled = true
                    return
                }
            }

            // If there is an identifier, and does not equal this subscription's identifier, ignore the error.
            if identifier != subscriptionItem.identifier {
                return
            }
        }

        if case ConnectionProviderError.other = error {
            AppSyncLogger.warn("[AppSyncSubscriptionConnection] \(#function): other error \(subscriptionItem.identifier)")
            // Again this is only ever returned if there is no `id` and it is not LimitExceeded
            // the default case should also be throttled at the subscription as we don't know whether it
            // happened because of this subscription
            // of because of something else.
            subscriptionItem.subscriptionEventHandler(.failed(error), subscriptionItem)
            return
        }
        
        

        AppSyncSubscriptionConnection.logExtendedErrorInfo(for: error)

        subscriptionState = .notSubscribed
        guard let retryHandler = retryHandler,
            let connectionError = error as? ConnectionProviderError
        else {
            subscriptionItem.subscriptionEventHandler(.failed(error), subscriptionItem)
            return
        }

        let retryAdvice = retryHandler.shouldRetryRequest(for: connectionError)
        if retryAdvice.shouldRetry, let retryInterval = retryAdvice.retryInterval {
            AppSyncLogger.debug("[AppSyncSubscriptionConnection] Retrying subscription \(subscriptionItem.identifier) after \(retryInterval)")
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) {
                self.connectionProvider?.connect()
            }
        } else {
            subscriptionItem.subscriptionEventHandler(.failed(error), subscriptionItem)
        }
    }

    public static func logExtendedErrorInfo(for error: Error) {
        switch error {
        case let typedError as ConnectionProviderError:
            logExtendedErrorInfo(for: typedError)
        case let typedError as WSError:
            logExtendedErrorInfo(for: typedError)
        case let typedError as NSError:
            logExtendedErrorInfo(for: typedError)
        default:
            AppSyncLogger.error(error)
        }
    }

    private static func logExtendedErrorInfo(for error: ConnectionProviderError) {
        switch error {
        case .connection:
            AppSyncLogger.error("ConnectionProviderError.connection")
        case .jsonParse(let identifier, let underlyingError):
            AppSyncLogger.error(
                """
                ConnectionProviderError.jsonParse; \
                identifier=\(identifier ?? "(N/A)"); \
                underlyingError=\(underlyingError?.localizedDescription ?? "(N/A)")
                """
            )
        case .limitExceeded(let identifier):
            AppSyncLogger.error(
                """
                ConnectionProviderError.limitExceeded; \
                identifier=\(identifier ?? "(N/A)");
                """
            )
        case .subscription(let identifier, let errorPayload):
            AppSyncLogger.error(
                """
                ConnectionProviderError.jsonParse; \
                identifier=\(identifier); \
                additionalInfo=\(String(describing: errorPayload))
                """
            )
        case .other:
            AppSyncLogger.error("ConnectionProviderError.other")
        }
    }

    private static func logExtendedErrorInfo(for error: WSError) {
        AppSyncLogger.error(error)
    }

    private static func logExtendedErrorInfo(for error: NSError) {
        AppSyncLogger.error(
            """
            NSError:\(error.domain); \
            code:\(error.code); \
            userInfo:\(error.userInfo)
            """
        )
    }

}

extension WSError: CustomStringConvertible {
    public var description: String {
        """
        WSError:\(message); \
        code:\(code); \
        type:\(type)
        """
    }
}
