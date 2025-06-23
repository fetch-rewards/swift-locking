//
//  LockType.swift
//
//  Copyright © 2025 Fetch.
//

import Foundation

/// A type of unfair lock.
public enum LockType: String {

    // MARK: Cases

    /// A checked unfair lock.
    case checked

    /// An unchecked unfair lock.
    case unchecked
}
