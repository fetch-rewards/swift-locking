//
//  LockedMacro+MacroArguments.swift
//
//  Copyright © 2025 Fetch.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxSugar

extension LockedMacro {

    /// Arguments provided to `@MockedMacro`.
    struct MacroArguments {

        // MARK: Properties

        /// The type of lock.
        let lockType: LockType

        // MARK: Initializers

        /// Creates macro arguments parsed from the provided `node`.
        ///
        /// - Parameter node: The node representing the macro.
        init(node: AttributeSyntax) throws {
            guard
                let arguments = node.arguments?.as(LabeledExprListSyntax.self),
                arguments.count > .zero
            else {
                throw MacroError.noArguments
            }

            let argument: (Int) -> LabeledExprSyntax? = { index in
                let argumentIndex = arguments.index(at: index)

                return arguments.count > index ? arguments[argumentIndex] : nil
            }

            guard let lockTypeArgument = argument(0) else {
                throw MacroError.unableToParseLockTypeArgument
            }

            self.lockType = try LockType(argument: lockTypeArgument)
        }
    }
}
