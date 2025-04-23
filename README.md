# Swift Synchronization

[![ci](https://github.com/fetch-rewards/swift-synchronization/actions/workflows/ci.yml/badge.svg)](https://github.com/fetch-rewards/swift-synchronization/actions/workflows/ci.yml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/fetch-rewards/swift-synchronization/graph/badge.svg?token=HfHbjO7HH6)](https://codecov.io/gh/fetch-rewards/swift-synchronization)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/fetch-rewards/swift-synchronization/blob/main/LICENSE)

Swift Synchronization is a collection of Swift macros used to protect mutable state.

- [Example](#example)
- [Installation](#installation)
- [Usage](#usage)
- [Macros](#macros)
  - [`@Locked`](#locked)
    - [`LockType`](#locktype) 
    - [Default Value](#default-value) 
- [Contributing](#contributing)
- [License](#license)

## Example

```swift
class Locks {
    @Locked(.checked)
    var count: Int

    init(count: Int) {
        self.count = count
    }
}
```

## Installation

To add Swift Synchronization to a Swift package manifest file:
- Add the `swift-synchronization` package to your package's `dependencies`:
  ```swift
  .package(
      url: "https://github.com/fetch-rewards/swift-synchronization.git",
      from: "<#latest swift-synchronization tag#>"
  )
  ```
- Add the `Synchronization` product to your target's `dependencies`:
  ```swift
  .product(name: "Synchronization", package: "swift-synchronization")
  ```

## Usage

Import `Synchronization`:
```swift
import Synchronization
```

Attach the `@Locked` macro to your property:
```swift
@Locked(.checked)
var count: Int
```

And that's it! Access to your property's underlying data is now synchronized using an `OSAllocatedUnfairLock`. You can continue 
to use your property just as you normally would, without ever needing to directly access the private, underscored property that 
is managing mutual exclusion for you.

> [!IMPORTANT]
> The property to which `@Locked` is attached must be a `var` and must have an explicit type:
> ```swift
> // Valid:
> var count: Int = .zero
> var count = Int.zero
> var count = Int(1)
>
> // Invalid:
> var count = 1
> let count: Int = .zero
> ```

`@Locked` must be initialized with a `lockType`. If your property's type conforms to `Sendable`, use `@Locked(.checked)`, otherwise 
use `@Locked(.unchecked)`.

> [!WARNING]
> `@Locked` uses `OSAllocatedUnfairLock` to protect shared state. This is useful when you need fast, low-level mutual exclusion and
> can manage the following limitations:
> - The lock is unfair by design. It may repeatedly favor certain threads over others. This can result in:
>   - **Thread Starvation**: Some threads might experience indefinite delays in acquiring the lock under high contention.
>   - **Unpredictable Ordering**: Operations that are meant to be “relative” (e.g. thread A before thread B) may not happen in that
>     order. This can lead to unexpected behavior when the sequence of operations matters.
> - `OSAllocatedUnfairLock` only guarantees mutual exclusion, not memory ordering beyond what is needed for the lock.
>   - If you perform complex relative logic across multiple locks or shared state, you may still get races or undefined behavior,
>     especially without proper memory barriers.
> - Locking does not prevent logic bugs.
>   - You might lock correctly but still compare stale values.
>   - You could perform multiple operations atomically in your mind, but they’re not in reality.
>
> For more complex synchronization requirements or when fairness is crucial, consider using higher-level constructs provided by Swift
> concurrency or Grand Central Dispatch.

## Macros

Swift Synchronization contains the Swift macro `@Locked`.

### `@Locked`

`@Locked` is an attached, peer and accessor macro that generates a private, protected, underscored backing property along 
with accessors for reading from and writing to that backing property:
```swift
@Locked(.checked)
var count: Int

// Generates:

var count: Int {
    @storageRestrictions(initializes: _count)
    init(initialValue) {
        self._count = OSAllocatedUnfairLock<Int>(
            initialState: initialValue
        )
    }
    get {
        self._count.withLock { count in
            count
        }
    }
    set {
        self._count.withLock { count in
            count = newValue
        }
    }
}

private let _count: OSAllocatedUnfairLock<Int>
```

The backing property uses `OSAllocatedUnfairLock` to synchronize access to its underlying data while the exposed property's 
accessors allow consumers to interact with this data without interfacing directly with `OSAllocatedUnfairLock`'s API.

#### `LockType`

`@Locked` takes a single argument: `lockType`. The possible values are `.checked` and `.unchecked`. 

If your property's type conforms to `Sendable`, use `.checked`:
```swift
@Locked(.checked)
var count: Int

// Generates:

var count: Int {
    @storageRestrictions(initializes: _count)
    init(initialValue) {
        self._count = OSAllocatedUnfairLock<Int>(
            initialState: initialValue
        )
    }
    get {
        self._count.withLock { count in
            count
        }
    }
    set {
        self._count.withLock { count in
            count = newValue
        }
    }
}

private let _count: OSAllocatedUnfairLock<Int>
```

If your property's type does not conform to `Sendable`, use `.unchecked`:
```swift
@Locked(.unchecked)
var nonSendableInstance: NonSendableType

// Generates:

var nonSendableInstance: NonSendableType {
    @storageRestrictions(initializes: _nonSendableInstance)
    init(initialValue) {
        self._nonSendableInstance = OSAllocatedUnfairLock<NonSendableType>(
            uncheckedState: initialValue
        )
    }
    get {
        self._nonSendableInstance.withLockUnchecked { nonSendableInstance in
            nonSendableInstance
        }
    }
    set {
        self._nonSendableInstance.withLockUnchecked { nonSendableInstance in
            nonSendableInstance = newValue
        }
    }
}

private let _nonSendableInstance: OSAllocatedUnfairLock<NonSendableType>
```

#### Default Value

The property to which `@Locked` is attached can be defined **_with_** (`var count: Int = .zero`) or **_without_** (`var count: Int`)
a default value. 

Providing a default value (`var count: Int = .zero`) results in two generated accessors - `get` and `set`:
```swift
get {
    self._count.withLock { count in
        count
    }
}
set {
    self._count.withLock { count in
        count = newValue
    }
}
```

Not providing a default value (`var count: Int`) results in an additional generated accessor - `init`:
```swift
@storageRestrictions(initializes: _count)
init(initialValue) {
    self._count = OSAllocatedUnfairLock<Int>(
        initialState: initialValue
    )
}
```

This `init` accessor allows you to assign a value to your property inside your object's initializer:
```swift
class Locks {
    @Locked(.checked)
    var count: Int

    init(count: Int) {
        self.count = count
    }
}
```

## Contributing

The simplest way to contribute to this project is by [opening an issue](https://github.com/fetch-rewards/swift-synchronization/issues/new).

If you would like to contribute code to this project, please read our [Contributing Guidelines](https://github.com/fetch-rewards/swift-synchronization/blob/main/CONTRIBUTING.md).

By opening an issue or contributing code to this project, you agree to follow our [Code of Conduct](https://github.com/fetch-rewards/swift-synchronization/blob/main/CODE_OF_CONDUCT.md).

## License

This library is released under the MIT license. See [LICENSE](https://github.com/fetch-rewards/swift-synchronization/blob/main/LICENSE) for details.
