# AppSync RealTime Client for iOS

## 1.2.1

### Misc

- Make SubscriptionItem.init public. See [PR #19](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/19)

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
