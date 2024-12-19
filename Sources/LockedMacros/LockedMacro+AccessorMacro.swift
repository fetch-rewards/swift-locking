//
//  LockedMacro+AccessorMacro.swift
//
//  Created by Gray Campbell.
//  Copyright © 2024 Fetch.
//

public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros
import SwiftSyntaxSugar

extension LockedMacro: AccessorMacro {

    // MARK: AccessorMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let lockType = try self.lockType(from: node)
        let (name, type, value) = try self.propertyComponents(
            from: declaration,
            with: lockType
        )
        let lockFunctionName = self.lockFunctionName(lockType: lockType)

        let getAccessor = try self.lockedPropertyGetAccessor(
            propertyName: name,
            lockFunctionName: lockFunctionName
        )
        let setAccessor = try self.lockedPropertySetAccessor(
            propertyName: name,
            lockFunctionName: lockFunctionName
        )

        guard value == nil else {
            return [
                getAccessor,
                setAccessor,
            ]
        }

        let initAccessor = self.lockedPropertyInitAccessor(
            lockType: lockType,
            type: type,
            propertyName: name
        )

        return [
            initAccessor,
            getAccessor,
            setAccessor,
        ]
    }

    // MARK: Locked Property Accessors

    /// Returns an `init` accessor for a locked property with the provided
    /// `propertyName`.
    ///
    /// ## Example
    /// ```swift
    /// @storageRestrictions(initializes: _propertyName)
    /// init(initialValue) {
    ///     self._propertyName = OSAllocatedUnfairLock<PropertyType>(
    ///         initialState: initialValue
    ///     )
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - lockType: The type of lock to use.
    ///   - type: The type of the property being locked.
    ///   - propertyName: The name of the property being locked.
    /// - Returns: An `init` accessor for a locked property with the provided
    ///   `propertyName`.
    private static func lockedPropertyInitAccessor(
        lockType: LockType,
        type: some TypeSyntaxProtocol,
        propertyName: TokenSyntax
    ) -> AccessorDeclSyntax {
        // _propertyName
        let backingPropertyReference = DeclReferenceExprSyntax(
            baseName: .identifier("_\(propertyName)")
        )

        // @storageRestrictions(initializes: _propertyName)
        let attributes = AttributeListSyntax {
            AttributeSyntax(
                atSign: .atSignToken(),
                attributeName: IdentifierTypeSyntax(
                    name: .identifier("storageRestrictions")
                ),
                leftParen: .leftParenToken(),
                arguments: .argumentList(
                    LabeledExprListSyntax {
                        LabeledExprSyntax(
                            label: .identifier("initializes"),
                            colon: .colonToken(),
                            expression: backingPropertyReference
                        )
                    }
                ),
                rightParen: .rightParenToken()
            )
        }

        // initialValue
        let initialValue: TokenSyntax = .identifier("initialValue")

        // @storageRestrictions(initializes: _propertyName) init(initialValue) { ... }
        return AccessorDeclSyntax(
            attributes: attributes,
            accessorSpecifier: .keyword(
                .`init`,
                leadingTrivia: .newline
            ),
            parameters: AccessorParametersSyntax(
                leftParen: .leftParenToken(),
                name: initialValue,
                rightParen: .rightParenToken()
            )
        ) {
            // self._propertyName = OSAllocatedUnfairLock(...: initialValue)
            SequenceExprSyntax {
                // self._propertyName
                MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .keyword(.self)
                    ),
                    period: .periodToken(),
                    declName: backingPropertyReference
                )

                // =
                AssignmentExprSyntax(equal: .equalToken())

                // OSAllocatedUnfairLock(...: initialValue)
                self.osAllocatedUnfairLockInitialization(
                    lockType: lockType,
                    type: type,
                    value: DeclReferenceExprSyntax(baseName: initialValue)
                )
            }
        }
    }

    /// Returns a `get` accessor for a locked property with the provided
    /// `propertyName`.
    ///
    /// ## Example
    /// ```swift
    /// get {
    ///     self._propertyName.withLock { propertyName in
    ///         propertyName
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - propertyName: The name of the property being locked.
    ///   - lockFunctionName: The name of the `withLock` function.
    /// - Returns: A `get` accessor for a locked property with the provided
    ///   `propertyName`.
    private static func lockedPropertyGetAccessor(
        propertyName: TokenSyntax,
        lockFunctionName: TokenSyntax
    ) throws -> AccessorDeclSyntax {
        try AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
            try self.backingPropertyWithLockFunctionCallExpression(
                propertyName: propertyName,
                lockFunctionName: lockFunctionName
            ) {
                DeclReferenceExprSyntax(baseName: propertyName)
            }
        }
    }

    /// Returns a `set` accessor for a locked property with the provided
    /// `propertyName`.
    ///
    /// ## Example
    /// ```swift
    /// set {
    ///     self._propertyName.withLock { propertyName in
    ///         propertyName = newValue
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - propertyName: The name of the property being locked.
    ///   - lockFunctionName: The name of the `withLock` function.
    /// - Returns: A `set` accessor for a locked property with the provided
    ///   `propertyName`.
    private static func lockedPropertySetAccessor(
        propertyName: TokenSyntax,
        lockFunctionName: TokenSyntax
    ) throws -> AccessorDeclSyntax {
        try AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
            try self.backingPropertyWithLockFunctionCallExpression(
                propertyName: propertyName,
                lockFunctionName: lockFunctionName
            ) {
                SequenceExprSyntax {
                    DeclReferenceExprSyntax(baseName: propertyName)
                    AssignmentExprSyntax(equal: .equalToken())
                    DeclReferenceExprSyntax(baseName: .identifier("newValue"))
                }
            }
        }
    }

    // MARK: Lock Function

    /// Returns the `withLock` function name associated with the provided
    /// `lockType`.
    ///
    /// - Parameter lockType: The type of lock to use to determine the
    ///   `withLock` function name.
    /// - Returns: The `withLock` function name associated with the provided
    ///   `lockType`.
    private static func lockFunctionName(lockType: LockType) -> TokenSyntax {
        switch lockType {
        case .checked:
            .identifier("withLock")
        case .unchecked:
            .identifier("withLockUnchecked")
        }
    }

    /// Returns a `withLock` function call expression for accessing the backing
    /// property for the property with the provided `propertyName`.
    ///
    /// ## Example
    /// ```swift
    /// self._propertyName.withLock { propertyName in
    ///     // lockClosureStatementsBuilder
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - propertyName: The name of the property being locked.
    ///   - lockFunctionName: The name of the `withLock` function.
    ///   - lockClosureStatementsBuilder: The statements builder for the
    ///     `withLock` closure.
    /// - Returns: A `withLock` function call expression for accessing the
    ///   backing property for the property with the provided `propertyName`.
    private static func backingPropertyWithLockFunctionCallExpression(
        propertyName: TokenSyntax,
        lockFunctionName: TokenSyntax,
        @CodeBlockItemListBuilder lockClosureStatementsBuilder: () throws -> CodeBlockItemListSyntax
    ) throws -> FunctionCallExprSyntax {
        // self._propertyName
        let backingPropertyAccessExpression = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
            period: .periodToken(),
            declName: DeclReferenceExprSyntax(
                baseName: .identifier("_\(propertyName)")
            )
        )

        // self._propertyName.withLock
        let backingPropertyWithLockAccessExpression = MemberAccessExprSyntax(
            base: backingPropertyAccessExpression,
            period: .periodToken(),
            declName: DeclReferenceExprSyntax(baseName: lockFunctionName)
        )

        // self._propertyName.withLock { propertyName in ... }
        return FunctionCallExprSyntax(
            calledExpression: backingPropertyWithLockAccessExpression,
            arguments: [],
            trailingClosure: try ClosureExprSyntax(
                leftBrace: .leftBraceToken(),
                signature: ClosureSignatureSyntax(
                    parameterClause: .simpleInput(
                        ClosureShorthandParameterListSyntax {
                            ClosureShorthandParameterSyntax(name: propertyName)
                        }
                    ),
                    inKeyword: .keyword(.in)
                ),
                rightBrace: .rightBraceToken(),
                statementsBuilder: lockClosureStatementsBuilder
            )
        )
    }
}
