# Changelog

All notable changes to this project will be documented in this file. 

This project adheres to [Semantic Versioning](https://semver.org).

## 📦 [Version 0.1.0](https://github.com/fetch-rewards/swift-locking/releases/tag/0.1.0) - April 23, 2025 ([Full Changelog](https://github.com/fetch-rewards/swift-locking/commits/0.1.0))

### 🚀 Initial Release

This is the first public release of Swift Locking, a library that provides a collection of Swift macros used to protect shared mutable state.

This initial release includes:

- `@Locked` - an attached peer and accessor macro that uses `OSAllocatedUnfairLock` to provide mutual exclusion for the property to which it's attached.
