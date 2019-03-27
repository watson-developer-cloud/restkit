
# [3.0.0](https://github.com/watson-developer-cloud/restkit/compare/2.0.0...3.0.0) (2019-03-28)

### Features

* Add RestError.deserialization
* Return `RestResponse` with response headers for error responses
* Add `metadata` associated value to `RestError.other`
* Add build step to run Swiftlint

### Bug Fixes

* Capture IAM token to avoid reauthentication


# [2.0.0](https://github.com/watson-developer-cloud/restkit/compare/1.3.0...2.0.0) (2018-11-30)

### Features

* Update the supported versions of Xcode, Swift, and iOS
* Improve the usefulness of `RestResponse`
* Improve the usefulness of `RestError`. Replace usage of `Error` with `RestError`.
* Remove `RestRequest.responseString()`. Use `RestRequest.response()` instead.
* Better error handling for `RestRequest.responseObject()`
* Get rid of default value for `RestRequest.userAgent`


# [1.3.0](https://github.com/watson-developer-cloud/restkit/compare/1.2.0...1.3.0) (2018-10-09)

### Features

* Add new `append` method to `MultipartFormData` that properly converts a file to `Data`, then appending the data to the request body.


# [1.2.0](https://github.com/watson-developer-cloud/swift-sdk/compare/1.1.0...1.2.0) (2018-09-10)

### Bug Fixes

* Improves the bug fix from version 1.1.0. `RestRequest.userAgent` should be set instead of `RestRequest.sdkVersion`.


# [1.1.0]((https://github.com/watson-developer-cloud/restkit/compare/1.0.0...1.1.0)) (2018-09-04)

### Bug Fixes

* Incorrect Watson SDK version was being used in the "User-agent" header for all network requests. This value should now be set using the new `RestRequest.sdkVersion` property.


# [1.0.0](https://github.com/watson-developer-cloud/restkit/tree/1.0.0) (2018-09-04)

This is the first standalone version. RestKit was previously integrated directly with the IBM Watson Swift SDK up until version v0.32.0.

