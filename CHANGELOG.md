# Changelog

All notable changes to this project will be documented in this file. 

This project adheres to [Semantic Versioning](https://semver.org).

## 📦 [Version 0.2.0](https://github.com/fetch-rewards/swift-locking/releases/tag/0.2.0) - June 25, 2025 ([Full Changelog](https://github.com/fetch-rewards/swift-locking/compare/0.1.0...0.2.0))

### <a name="breaking-changes-0.2.0"></a>Breaking Changes

- Rename package to Swift Locking ([#35](https://github.com/fetch-rewards/swift-locking/pull/35))
    - References to the package URL should be changed to `"https://github.com/fetch-rewards/swift-locking.git"`.
    - References to the package product must be changed to `.product(name: "Locking", package: "swift-locking")`.
    - Import statements must be changed to `import Locking`.

> [!NOTE]
> Historical changelog entries before this version may reference the old repository name: Swift Synchronization.

### Bug Fixes

- **[[BREAKING](#breaking-changes-0.2.0)]** Rename package to Swift Locking ([#35](https://github.com/fetch-rewards/swift-locking/pull/35))

### Documentation

- Add SPI badges to README ([#28](https://github.com/fetch-rewards/swift-locking/pull/28))
- Fix spelling mistake ([#30](https://github.com/fetch-rewards/swift-locking/pull/30))
- Add more issue templates ([#31](https://github.com/fetch-rewards/swift-locking/pull/31))

### Formatting

- Remove author from file headers ([#29](https://github.com/fetch-rewards/swift-locking/pull/29))

### Dependencies

- Update SwiftFormat minimum version and output version in CI ([#33](https://github.com/fetch-rewards/swift-locking/pull/33))
- Update SwiftSyntax dependency URL ([#36](https://github.com/fetch-rewards/swift-locking/pull/36))

### CI/CD

- Add CODEOWNERS ([#32](https://github.com/fetch-rewards/swift-locking/pull/32))
- Update SwiftFormat minimum version and output version in CI ([#33](https://github.com/fetch-rewards/swift-locking/pull/33))

## 📦 [Version 0.1.0](https://github.com/fetch-rewards/swift-locking/releases/tag/0.1.0) - April 23, 2025 ([Full Changelog](https://github.com/fetch-rewards/swift-locking/commits/0.1.0))

### 🚀 Initial Release

This is the first public release of Swift Synchronization, a library that provides a collection of Swift macros used to protect shared mutable state.

This initial release includes:

- `@Locked` - an attached peer and accessor macro that uses `OSAllocatedUnfairLock` to provide mutual exclusion for the property to which it's attached.
