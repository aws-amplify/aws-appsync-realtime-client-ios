# AppSync RealTime Client for iOS

## Unreleased

- *Changes on `main` branch that have not yet been released*

## 1.4.2

### Bug fixes

- Fix implicitly unwrapped subscriptionItem (See [Issue #33](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/issues/33), [PR #35](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/35))
- Fix data races in CountdownTimer (See [PR #37](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/37))

## 1.4.1

### Misc

- Updated Cartfile with correct version of StarScream

## 1.4.0

### Bug fixes

- Fix stale connection handling upon resume from background ([#25](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/25)). Also see issues:
  - https://github.com/aws-amplify/amplify-ios/issues/677
  - https://github.com/aws-amplify/aws-appsync-realtime-client-ios/issues/24
  - https://github.com/awslabs/aws-mobile-appsync-sdk-ios/issues/393
  - https://github.com/awslabs/aws-mobile-appsync-sdk-ios/issues/396
  - https://github.com/awslabs/aws-mobile-appsync-sdk-ios/issues/403

### Misc

- AppSync RealTime Client for iOS is now released under the Apache 2.0 license. See [LICENSE](./LICENSE) for details. ([#26](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/issues/26))

## 1.3.0

### Misc

- Make SubscriptionItem.init public. See [PR #19](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/19)
- Update CocoaPods JSON gem dependency. See [PR #20](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/20)
- Fix integration tests instructions and add test schema to support files. See [PR #21](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/21)

## 1.2.0

### Misc

- Upgrade Starscream to ~> 3.1.0. See [PR #17](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/17)

## 1.1.6

### Improvements

- Socket Disconnect when no remaining subscriptions. See [PR #8](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/8)

## 1.1.5

### Bug fix

- Added necessary files required for Carthage users. See [PR #12](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/12) [PR #13](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/13) 

## 1.1.0

### Improvements

- Add Interceptors and Connection Provider Factory to allow consumers more easily create websocket connections. See [PR #4](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/4) for more details.
- Fix subscription threading issue by moving websocket writes into separate queue. See [PR #7](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/7)

## 1.0.2 (deprecated)

### Improvements

Add Interceptors and Connection Provider Factory to allow consumers more easily create websocket connections. See [PR #4](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/4) for more details.

## 1.0.1

### Bug Fixes
- Changed the variable in subscription to get nil as the data in the dictionary. See [PR #3](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/3)

## 1.0.0
Initial commit
