# AppSync RealTime Client for iOS

## 1.1.4

- Added necessary files required for Carthage users. See [PR #12](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/12) [PR #13](https://github.com/aws-amplify/aws-appsync-realtime-client-ios/pull/13) 

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
