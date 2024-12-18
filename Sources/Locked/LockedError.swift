//
//  LockedError.swift
//  Locked
//
//  Created by Gray Campbell on 12/18/24.
//

import Foundation

/// An error thrown by the ``Locked`` macro.
public enum LockedError: Error, CustomStringConvertible {

    // MARK: Cases

    /// Attempted access of a locked property using `withLockIfAvailable` failed
    /// because the lock is unavailable.
    case withLockIfAvailableValueIsNil

    // MARK: Properties

    public var description: String {
        switch self {
        case .withLockIfAvailableValueIsNil:
            "withLockIfAvailable is unavailable."
        }
    }
}
