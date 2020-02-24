# TestEZ Changelog

## Current master
* Added support for init.spec.lua. Code in this file is treated as belonging to the directory's node in the test tree. This allows for lifecycle hooks to be attached to all files in a directory.

## 0.1.1 (2020-01-23)
* Added beforeAll, beforeEach, afterEach, afterAll lifecycle hooks for testing
	* The setup and teardown behavior of these hooks attempt to reach feature parity with [jest](https://jestjs.io/docs/en/setup-teardown).


## 0.1.0 (2019-11-01)
* Initial release.
