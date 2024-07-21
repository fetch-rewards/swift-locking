//
//  LockedMacro+PeerMacro.swift
//  LockedMacros
//
//  Created by Gray Campbell on 7/21/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxSugar

extension LockedMacro: PeerMacro {

    // MARK: PeerMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let (name, type, value) = try self.parsedProperty(from: declaration)

        // private
        let modifiers = DeclModifierListSyntax {
            DeclModifierSyntax(name: .keyword(.private))
        }

        // OSAllocatedUnfairLock<PropertyType>
        let osAllocatedUnfairLock = GenericSpecializationExprSyntax(
            expression: DeclReferenceExprSyntax(
                baseName: .identifier("OSAllocatedUnfairLock")
            ),
            genericArgumentClause: GenericArgumentClauseSyntax {
                GenericArgumentSyntax(argument: type)
            }
        )

        // OSAllocatedUnfairLock<PropertyType>(initialState: propertyValue)
        let osAllocatedUnfairLockInitialization = FunctionCallExprSyntax(
            calledExpression: osAllocatedUnfairLock,
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(
                    label: self.osAllocatedUnfairLockInitializerLabel(node: node),
                    colon: .colonToken(),
                    expression: value
                )
            },
            rightParen: .rightParenToken()
        )

        // _propertyName = OSAllocatedUnfairLock<PropertyType>(...)
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "_\(name)"),
            initializer: InitializerClauseSyntax(
                value: osAllocatedUnfairLockInitialization
            )
        )

        // private let _propertyName = OSAllocatedUnfairLock<PropertyType>(...)
        let backingProperty = VariableDeclSyntax(
            modifiers: modifiers,
            bindingSpecifier: .keyword(.let),
            bindings: [binding]
        )

        return [DeclSyntax(backingProperty)]
    }

    // MARK: OSAllocatedUnfairLock Initializer

    private static func osAllocatedUnfairLockInitializerLabel(
        node: AttributeSyntax
    ) -> TokenSyntax {
        switch self.lockType(from: node) {
        case .checked, .ifAvailableChecked:
            .identifier("initialState")
        case .unchecked, .ifAvailableUnchecked:
            .identifier("uncheckedState")
        }
    }
}
