//
//  LockedMacro.swift
//
//  Created by Gray Campbell.
//  Copyright © 2024 Fetch.
//

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
    static func lockType(from node: AttributeSyntax) throws -> LockType {
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
            throw LockedMacroError.invalidLockType
        }

        return lockType
    }

    // MARK: Property Components

    /// Returns property components (`name`, `type`, and `value`) parsed from
    /// the provided declaration.
    ///
    /// - Parameters:
    ///   - declaration: The declaration from which to parse the property
    ///     components.
    ///   - lockType: The type of lock applied to the property declaration.
    /// - Returns: Property components (`name`, `type`, and `value`) parsed from
    ///   the provided declaration.
    static func propertyComponents(
        from declaration: some DeclSyntaxProtocol,
        with lockType: LockType
    ) throws -> (
        name: TokenSyntax,
        type: any TypeSyntaxProtocol,
        value: (any ExprSyntaxProtocol)?
    ) {
        guard let propertyDeclaration = declaration.as(VariableDeclSyntax.self) else {
            throw LockedMacroError.declarationMustBeProperty
        }

        guard propertyDeclaration.bindingSpecifier.tokenKind == .keyword(.var) else {
            throw LockedMacroError.propertyDeclarationBindingSpecifierMustBeVar
        }

        guard
            propertyDeclaration.bindings.count == 1,
            let binding = propertyDeclaration.bindings.first
        else {
            throw LockedMacroError.propertyDeclarationMustHaveExactlyOneBinding
        }

        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw LockedMacroError.bindingPatternMustBeIdentifierPattern
        }

        let name = pattern.identifier.trimmed
        let type = try self.type(from: binding)
        let value = binding.initializer?.value.trimmed

        if lockType == .ifAvailableChecked || lockType == .ifAvailableUnchecked {
            var isTypeOptional = type.is(OptionalTypeSyntax.self)

            if !isTypeOptional, let identifierType = type.as(IdentifierTypeSyntax.self) {
                let identifierTypeName = identifierType.name.trimmed

                isTypeOptional = identifierTypeName.tokenKind == .identifier("Optional")
            }

            guard isTypeOptional else {
                throw LockedMacroError.ifAvailableLockRequiresOptionalType
            }
        }

        return (name, type, value)
    }

    /// Returns a type parsed from the provided binding.
    ///
    /// - Parameter binding: The binding from which to parse the type.
    /// - Throws: An error if a type could not be parsed from the provided
    ///   binding.
    /// - Returns: A type parsed from the provided binding.
    private static func type(
        from binding: PatternBindingSyntax
    ) throws -> TypeSyntax {
        if let type = binding.typeAnnotation?.type {
            return type.trimmed
        } else if
            let memberAccessExpression = binding.initializer?.value.as(
                MemberAccessExprSyntax.self
            ),
            let base = memberAccessExpression.base
        {
            return "\(base.trimmed)"
        } else if let functionCallExpression = binding.initializer?.value.as(
            FunctionCallExprSyntax.self
        ) {
            let calledExpression = functionCallExpression.calledExpression

            return "\(calledExpression.trimmed)"
        } else {
            throw LockedMacroError.bindingPatternMustHaveTypeInformation
        }
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
    /// the provided `lockType`.
    ///
    /// - Parameter lockType: The type of lock to use.
    /// - Returns: The `OSAllocatedUnfairLock` initializer label to use based on
    ///   the provided `lockType`.
    static func osAllocatedUnfairLockInitializerLabel(
        lockType: LockType
    ) -> TokenSyntax {
        switch lockType {
        case .checked, .ifAvailableChecked:
            .identifier("initialState", leadingTrivia: .newline)
        case .unchecked, .ifAvailableUnchecked:
            .identifier("uncheckedState", leadingTrivia: .newline)
        }
    }

    /// Returns an `OSAllocatedUnfairLock` initialization expression with the
    /// provided `type` and `value` and an initializer label determined based on
    /// the provided `lockType`.
    ///
    /// - Parameters:
    ///   - lockType: The type of lock to use.
    ///   - type: The type with which to specialize `OSAllocatedUnfairLock`.
    ///   - value: The value with which to initialize `OSAllocatedUnfairLock`.
    /// - Returns: An `OSAllocatedUnfairLock` initialization expression with the
    ///   provided `type` and `value` and an initializer label determined based
    ///   on the provided `lockType`.
    static func osAllocatedUnfairLockInitialization(
        lockType: LockType,
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
                    label: self.osAllocatedUnfairLockInitializerLabel(
                        lockType: lockType
                    ),
                    colon: .colonToken(),
                    expression: value
                )
            },
            rightParen: .rightParenToken(leadingTrivia: .newline)
        )
    }
}
