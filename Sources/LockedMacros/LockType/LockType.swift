//
//  LockType.swift
//
//  Created by Gray Campbell.
//  Copyright © 2024 Fetch.
//

import SwiftSyntax

/// A type of unfair lock.
enum LockType: String, CaseIterable, Equatable {

    // MARK: Cases

    /// A checked unfair lock.
    case checked

    /// An unchecked unfair lock.
    case unchecked

    // MARK: Initializers

    /// Creates a ``LockType`` from the provided `argument`.
    ///
    /// - Parameter argument: The argument syntax from which to parse a
    ///   ``LockType``.
    /// - Throws: An error if a valid ``LockType`` cannot be parsed from the
    ///   provided `argument`.
    init(argument: LabeledExprSyntax) throws {
        guard
            let memberAccessExpression = argument.expression.as(
                MemberAccessExprSyntax.self
            ),
            let lockType = Self.allCases.first(where: { lockType in
                let declName = memberAccessExpression.declName

                return declName.baseName.tokenKind == .identifier(
                    lockType.rawValue
                )
            })
        else {
            throw ParsingError.unableToParseLockType
        }

        self = lockType
    }
}
