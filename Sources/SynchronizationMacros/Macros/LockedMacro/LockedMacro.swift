//
//  LockedMacro.swift
//
//  Copyright © 2025 Fetch.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxSugar

public struct LockedMacro {

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
            throw MacroError.canOnlyBeAppliedToPropertyDeclarations
        }

        guard propertyDeclaration.bindingSpecifier.tokenKind == .keyword(.var) else {
            throw MacroError.canOnlyBeAppliedToPropertyDeclarationsWithVarBindingSpecifier
        }

        guard
            propertyDeclaration.bindings.count == 1,
            let propertyBinding = propertyDeclaration.bindings.first
        else {
            throw MacroError.canOnlyBeAppliedToSingleBindingPropertyDeclarations
        }

        guard
            let propertyBindingPattern = propertyBinding.pattern.as(
                IdentifierPatternSyntax.self
            )
        else {
            throw MacroError.canOnlyBeAppliedToPropertyDeclarationsWithIdentifierBindingPattern
        }

        let name = propertyBindingPattern.identifier.trimmed
        let type = try self.type(from: propertyBinding)
        let value = propertyBinding.initializer?.value.trimmed

        return (name, type, value)
    }

    /// Returns a type parsed from the provided `propertyBinding`.
    ///
    /// - Parameter propertyBinding: The property binding from which to parse
    ///   the type.
    /// - Throws: An error if a type could not be parsed from the provided
    ///   `propertyBinding`.
    /// - Returns: A type parsed from the provided `propertyBinding`.
    private static func type(
        from propertyBinding: PatternBindingSyntax
    ) throws -> TypeSyntax {
        if let type = propertyBinding.typeAnnotation?.type {
            return type.trimmed
        } else if
            let memberAccessExpression = propertyBinding.initializer?.value.as(
                MemberAccessExprSyntax.self
            ),
            let base = memberAccessExpression.base
        {
            return "\(base.trimmed)"
        } else if let functionCallExpression = propertyBinding.initializer?.value.as(
            FunctionCallExprSyntax.self
        ) {
            let calledExpression = functionCallExpression.calledExpression

            return "\(calledExpression.trimmed)"
        } else {
            throw MacroError.unableToParseType
        }
    }

    // MARK: OSAllocatedUnfairLock

    /// Returns the type name for `OSAllocatedUnfairLock`.
    ///
    /// - Returns: The type name for `OSAllocatedUnfairLock`.
    static func osAllocatedUnfairLockTypeName() -> TokenSyntax {
        "OSAllocatedUnfairLock"
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
        case .checked:
            .identifier("initialState", leadingTrivia: .newline)
        case .unchecked:
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
            calledExpression: self.osAllocatedUnfairLockExprSyntax(type: type),
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
