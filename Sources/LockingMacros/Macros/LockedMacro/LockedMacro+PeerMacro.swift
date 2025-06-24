//
//  LockedMacro+PeerMacro.swift
//
//  Copyright © 2025 Fetch.
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
        let macroArguments = try MacroArguments(node: node)
        let (name, type, value) = try self.propertyComponents(
            from: declaration,
            with: macroArguments.lockType
        )
        let pattern = IdentifierPatternSyntax(identifier: "_\(name)")

        let binding: PatternBindingSyntax

        if let value {
            // OSAllocatedUnfairLock<PropertyType>(...: value)
            let osAllocatedUnfairLockInitialization = self.osAllocatedUnfairLockInitialization(
                lockType: macroArguments.lockType,
                type: type,
                value: value
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
                        name: self.osAllocatedUnfairLockTypeName(),
                        genericArgumentClause: GenericArgumentClauseSyntax {
                            GenericArgumentSyntax(argument: type)
                        }
                    )
                )
            )
        }

        // private let _propertyName = OSAllocatedUnfairLock<PropertyType>...
        let backingProperty = VariableDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.private))
            },
            bindingSpecifier: .keyword(.let),
            bindings: [binding]
        )

        return [DeclSyntax(backingProperty)]
    }
}
