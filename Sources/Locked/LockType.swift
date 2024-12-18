//
//  LockType.swift
//
//  Created by Gray Campbell.
//  Copyright © 2024 Fetch.
//

import Foundation

/// A type of unfair lock.
public enum LockType: String {

    // MARK: Cases

    /// A checked unfair lock.
    case checked

    /// An unchecked unfair lock.
    case unchecked
    case ifAvailableChecked
    case ifAvailableUnchecked
}
