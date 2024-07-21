//
//  LockedMacro.swift
//  MockedMacros
//
//  Created by Gray Campbell on 7/19/24.
//

import LockedArguments
public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros
import SwiftSyntaxSugar

public struct LockedMacro {

    // MARK: Lock Type

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

    // MARK: Parsed Property

    static func parsedProperty(
        from declaration: some DeclSyntaxProtocol
    ) throws -> (
        name: TokenSyntax,
        type: any TypeSyntaxProtocol,
        value: any ExprSyntaxProtocol
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
            fatalError("AHHHH")
        }

        guard let initializer = binding.initializer else {
            fatalError("AHHHH")
        }

        return (
            pattern.identifier.trimmed,
            type.trimmed,
            initializer.value.trimmed
        )
    }
}
