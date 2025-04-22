# swift-synchronization

[![ci](https://github.com/fetch-rewards/swift-synchronization/actions/workflows/ci.yml/badge.svg)](https://github.com/fetch-rewards/swift-synchronization/actions/workflows/ci.yml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/fetch-rewards/swift-synchronization/graph/badge.svg?token=HfHbjO7HH6)](https://codecov.io/gh/fetch-rewards/swift-synchronization)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/fetch-rewards/swift-synchronization/blob/main/LICENSE)

`swift-synchronization` is a collection of Swift macros used to protect mutable state.

- [Example](#example)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Example

## Installation

To add `swift-synchronization` to a Swift package manifest file:
- Add the `swift-synchronization` package to your package's `dependencies`:
  ```swift
  .package(
      url: "https://github.com/fetch-rewards/swift-synchronization.git",
      from: "<#latest swift-synchronization tag#>"
  )
  ```
- Add the `Locked` product to your target's `dependencies`:
  ```swift
  .product(name: "Locked", package: "swift-synchronization")
  ```

## Usage

- Import `Locked`:
  ```swift
  import Locked
  ```

## Contributing

The simplest way to contribute to this project is by [opening an issue](https://github.com/fetch-rewards/swift-synchronization/issues/new).

If you would like to contribute code to this project, please read our [Contributing Guidelines](https://github.com/fetch-rewards/swift-synchronization/blob/main/CONTRIBUTING.md).

By opening an issue or contributing code to this project, you agree to follow our [Code of Conduct](https://github.com/fetch-rewards/swift-synchronization/blob/main/CODE_OF_CONDUCT.md).

## License

This library is released under the MIT license. See [LICENSE](https://github.com/fetch-rewards/swift-synchronization/blob/main/LICENSE) for details.
