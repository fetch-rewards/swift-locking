//
//  LockedMacro+PeerMacro.swift
//  LockedMacros
//
//  Created by Gray Campbell on 7/21/24.
//

public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros
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

        let pattern = IdentifierPatternSyntax(identifier: "_\(name)")
        let typeName: TokenSyntax = .identifier("OSAllocatedUnfairLock")
        let genericArgumentClause = GenericArgumentClauseSyntax {
            GenericArgumentSyntax(argument: type)
        }

        let binding: PatternBindingSyntax

        if let value {
            // OSAllocatedUnfairLock<PropertyType>
            let osAllocatedUnfairLock = GenericSpecializationExprSyntax(
                expression: DeclReferenceExprSyntax(baseName: typeName),
                genericArgumentClause: genericArgumentClause
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
            binding = PatternBindingSyntax(
                pattern: pattern,
                initializer: InitializerClauseSyntax(
                    value: osAllocatedUnfairLockInitialization
                )
            )
        } else {
            // _propertyName: OSAllocatedUnfairLock<PropertyType>
            binding = PatternBindingSyntax(
                pattern: pattern,
                typeAnnotation: TypeAnnotationSyntax(
                    colon: .colonToken(),
                    type: IdentifierTypeSyntax(
                        name: typeName,
                        genericArgumentClause: genericArgumentClause
                    )
                )
            )
        }

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
