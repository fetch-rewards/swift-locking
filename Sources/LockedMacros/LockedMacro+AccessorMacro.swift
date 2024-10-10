//
//  LockedMacro+AccessorMacro.swift
//  LockedMacros
//
//  Created by Gray Campbell on 7/21/24.
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
        let (name, _, _) = try self.parsedProperty(from: declaration)
        let lockFunctionName = self.lockFunctionName(node: node)

        // get { ... }
        let getAccessor = try self.lockedPropertyAccessor(
            keyword: .get,
            propertyName: name,
            lockFunctionName: lockFunctionName
        ) {
            // propertyName
            DeclReferenceExprSyntax(baseName: name)
        }

        // set { ... }
        let setAccessor = try self.lockedPropertyAccessor(
            keyword: .set,
            propertyName: name,
            lockFunctionName: lockFunctionName
        ) {
            // propertyName = newValue
            SequenceExprSyntax {
                DeclReferenceExprSyntax(baseName: name)
                AssignmentExprSyntax(equal: .equalToken())
                DeclReferenceExprSyntax(baseName: .identifier("newValue"))
            }
        }

        return [
            getAccessor,
            setAccessor,
        ]
    }

    // MARK: Lock Function

    private static func lockFunctionName(node: AttributeSyntax) -> TokenSyntax {
        switch self.lockType(from: node) {
        case .checked:
            .identifier("withLock")
        case .unchecked:
            .identifier("withLockUnchecked")
        case .ifAvailableChecked:
            .identifier("withLockIfAvailable")
        case .ifAvailableUnchecked:
            .identifier("withLockIfAvailableUnchecked")
        }
    }

    // MARK: Locked Property Accessors

    /// Returns an accessor with the provided `keyword` for a locked property
    /// with the provided `propertyName`.
    ///
    /// ## Examples
    /// ```swift
    /// get {
    ///     self._propertyName.withLock { propertyName in
    ///         // lockClosureStatementsBuilder
    ///     }
    /// }
    /// set {
    ///     self._propertyName.withLock { propertyName in
    ///         // lockClosureStatementsBuilder
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - keyword: The accessor's keyword (i.e. `get` or `set`).
    ///   - propertyName: The name of the property being locked.
    ///   - lockClosureStatementsBuilder: The statements builder for the
    ///     accessor's `withLock` closure.
    /// - Returns: An accessor with the provided `keyword` for a locked property
    ///   with the provided `propertyName`.
    private static func lockedPropertyAccessor(
        keyword: Keyword,
        propertyName: TokenSyntax,
        lockFunctionName: TokenSyntax,
        @CodeBlockItemListBuilder
        lockClosureStatementsBuilder: () throws -> CodeBlockItemListSyntax
    ) throws -> AccessorDeclSyntax {
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
        let backingPropertyWithLockFunctionCallExpression = FunctionCallExprSyntax(
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

        return AccessorDeclSyntax(accessorSpecifier: .keyword(keyword)) {
            backingPropertyWithLockFunctionCallExpression
        }
    }
}
