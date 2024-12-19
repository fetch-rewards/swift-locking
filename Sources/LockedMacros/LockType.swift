//
//  LockType.swift
//  LockedMacros
//
//  Created by Gray Campbell on 7/21/24.
//

import Foundation

/// A type of unfair lock.
enum LockType: String {

    // MARK: Cases

    /// A checked unfair lock.
    case checked

    /// An unchecked unfair lock.
    case unchecked
}
