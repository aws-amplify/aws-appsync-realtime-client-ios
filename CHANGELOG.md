# AppSync RealTime Client for iOS

## Unreleased
*Changes on `main` branch that have not yet been released*

## 3.1.1
- fix: pin starscream to 4.0.4 ([#132](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/132))

## 3.1.0

### Features
- feat: Add async implementation and OIDCAuthProvider protocol ([#119](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/119))
- feat: Add asynchronous version of interceptor protocol ([#118](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/118))

### Misc
- chore: Update the pods ([#120](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/120))
- chore: fix build warnings ([#116](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/116))

## 3.0.0

**Breaking changes**: This is a major version release due to the changes made in [PR #110](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/110). The public interface for `ConnectionProviderFactory`, `RealtimeConnectionProviderAsync`, and `RealtimeConnectionProvider` has been modified to take in a `URLRequest` parameter instead of a `URL`.

### Features
- feat: pass URLRequest instead of URL to interfaces (See [PR #110](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/110))

### Fixes
- fix: fixed a bug that prevented TaskQueue sync method from waiting for the task to complete. (See [PR #107](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/107))
- chore: Add no store for the cache in urlsession (See [PR #109](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/109))

## 2.1.1

### Fixes

- fix: add runtime and compiler gates to OIDCAuthInterceptorAsync OIDCAuthProviderAsync and add files to workspace (See [PR #104](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/104))

## 2.1.0

### Features
- feat: added async oidc interceptor (See [PR #100](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/100))

### Fixes
- fix: sets OS versions for os_log (See [PR #99](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/99))
- fix: supports cross platform builds (See [PR #98](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/98))

## 2.0.0

- feat: Handle Unauthorized errors (See [PR #69](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/69))
- fix: rebase RTConnectionProvider+Websocket to Async version (See [PR #91](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/91))
- fix: create valid unauthorized request for odic/userpool connections (See [PR #93](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/93))

Breaking changes: `ConnectionProviderError.other` has been removed and `.unauthorized` and `.unknown` cases has been added.

## 1.10.0

### Features

- feat: Add Swift concurrency (async/await) support for async interceptors

## 1.9.1

### Bug fixes

- fix: Throttle AppSync LimitExceeded errors (See [PR #67](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/67))

## 1.9.0

### Features

- feat: Attempt to reconnect on connectivity (See [PR #58](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/58))

## 1.8.1

### Bug fixes

- fix: Subscription failed event should be terminal event (See [PR #74](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/74))

## 1.8.0

- feat: Allow setting log level (See [PR #71](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/71))

## 1.7.1

### Bug fixes

- fix: Retry on MaxSubscriptionReached (See [PR #66](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/66))
- fix: data race in CountdownTimer (See [PR #65](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/65))

## 1.7.0

- feat: Upgrade Starscream to 4.0.4 (See [PR #62](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/62))

## 1.6.0

- feat: Realtime interceptor changes for GraphQL subscriptions (See [PR #53](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/53))

## 1.5.0

### Feature

- feat: disconnect on last subscription, fix data races (See [PR #46](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/46))

### Misc

- Exclude resources file from SPM (See [PR #43](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/43))

## 1.4.4

### Feature

- AppSyncRealTimeClient can now be installed via Swift Package Manager. Thanks [@pjechris](https://github.com/pjechris)!

## 1.4.3

### Bug fixes

- Fix race condition in disconnect; protect status & write access (See [PR #40](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/40))

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
