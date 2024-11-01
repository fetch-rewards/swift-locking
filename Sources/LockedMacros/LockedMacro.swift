//
//  LockedMacro.swift
//  MockedMacros
//
//  Created by Gray Campbell on 7/19/24.
//

import LockedArguments
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxSugar

public struct LockedMacro {

    // MARK: Lock Type

    /// Returns the `LockType` parsed from the provided `node`.
    ///
    /// - Parameter node: The node from which to determine the `LockType`.
    /// - Returns: The `LockType` parsed from the provided `node`.
    static func lockType(from node: AttributeSyntax) -> LockType {
        let lockTypeRawValue = node
            .arguments?
            .as(LabeledExprListSyntax.self)?
            .first?
            .expression
            .as(MemberAccessExprSyntax.self)?
            .declName
            .baseName
            .trimmed
            .text

        guard 
            let lockTypeRawValue,
            let lockType = LockType(rawValue: lockTypeRawValue)
        else {
            return .checked
        }

        return lockType
    }

    // MARK: Property Components

    /// Returns property components (`name`, `type`, and `value`) parsed from
    /// the provided declaration.
    ///
    /// - Parameter declaration: The declaration from which to parse property
    ///   components.
    /// - Returns: Property components (`name`, `type`, and `value`) parsed from
    ///   the provided declaration.
    static func propertyComponents(
        from declaration: some DeclSyntaxProtocol
    ) throws -> (
        name: TokenSyntax,
        type: any TypeSyntaxProtocol,
        value: (any ExprSyntaxProtocol)?
    ) {
        guard let propertyDeclaration = declaration.as(VariableDeclSyntax.self) else {
            fatalError("AHHHH")
        }

        guard propertyDeclaration.bindingSpecifier.tokenKind == .keyword(.var) else {
            fatalError("AHHHH")
        }

        guard
            propertyDeclaration.bindings.count == 1,
            let binding = propertyDeclaration.bindings.first
        else {
            fatalError("AHHHH")
        }

        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            fatalError("AHHHH")
        }

        guard let type = binding.typeAnnotation?.type else {
            guard
                let initializer = binding.initializer,
                let functionCallExpression = initializer.value.as(
                    FunctionCallExprSyntax.self
                )
            else {
                fatalError("AHHHH")
            }

            let calledExpression = functionCallExpression.calledExpression

            return (
                pattern.identifier.trimmed,
                TypeSyntax(
                    stringLiteral: calledExpression.trimmedDescription
                ),
                initializer.value.trimmed
            )
        }

        return (
            pattern.identifier.trimmed,
            type.trimmed,
            binding.initializer?.value.trimmed
        )
    }

    // MARK: OSAllocatedUnfairLock

    /// Returns the type name for `OSAllocatedUnfairLock`.
    ///
    /// - Returns: The type name for `OSAllocatedUnfairLock`.
    static func osAllocatedUnfairLockTypeName() -> TokenSyntax {
        .identifier("OSAllocatedUnfairLock")
    }

    /// Returns the expression syntax for `OSAllocatedUnfairLock` specialized
    /// with the provided `type`.
    ///
    /// - Parameter type: The type with which to specialize
    ///   `OSAllocatedUnfairLock`.
    /// - Returns: The expression syntax for `OSAllocatedUnfairLock` specialized
    ///   with the provided `type`.
    static func osAllocatedUnfairLockExprSyntax(
        type: some TypeSyntaxProtocol
    ) -> GenericSpecializationExprSyntax {
        GenericSpecializationExprSyntax(
            expression: DeclReferenceExprSyntax(
                baseName: self.osAllocatedUnfairLockTypeName()
            ),
            genericArgumentClause: GenericArgumentClauseSyntax {
                GenericArgumentSyntax(argument: type)
            }
        )
    }

    /// Returns the `OSAllocatedUnfairLock` initializer label to use based on
    /// the `LockType` parsed from the provided `node`.
    ///
    /// - Parameter node: The node from which to determine the `LockType`.
    /// - Returns: The `OSAllocatedUnfairLock` initializer label to use based on
    ///   the `LockType` parsed from the provided `node`.
    static func osAllocatedUnfairLockInitializerLabel(
        node: AttributeSyntax
    ) -> TokenSyntax {
        switch self.lockType(from: node) {
        case .checked, .ifAvailableChecked:
            .identifier("initialState", leadingTrivia: .newline)
        case .unchecked, .ifAvailableUnchecked:
            .identifier("uncheckedState", leadingTrivia: .newline)
        }
    }

    /// Returns an `OSAllocatedUnfairLock` initialization expression with the
    /// provided `type` and `value` and an initializer label determined based on
    /// the `LockType` parsed from the provided `node`.
    ///
    /// - Parameters:
    ///   - node: The node from which to determine the `LockType`.
    ///   - type: The type with which to specialize `OSAllocatedUnfairLock`.
    ///   - value: The value with which to initialize `OSAllocatedUnfairLock`.
    /// - Returns: An `OSAllocatedUnfairLock` initialization expression with the
    ///   provided `type` and `value` and an initializer label determined based
    ///   on the `LockType` parsed from the provided `node`.
    static func osAllocatedUnfairLockInitialization(
        node: AttributeSyntax,
        type: some TypeSyntaxProtocol,
        value: some ExprSyntaxProtocol
    ) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            calledExpression: self.osAllocatedUnfairLockExprSyntax(
                type: type
            ),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(
                    label: self.osAllocatedUnfairLockInitializerLabel(node: node),
                    colon: .colonToken(),
                    expression: value
                )
            },
            rightParen: .rightParenToken(leadingTrivia: .newline)
        )
    }
}
