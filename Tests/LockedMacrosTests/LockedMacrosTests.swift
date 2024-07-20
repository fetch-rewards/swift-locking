import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not 
// available when cross-compiling. Cross-compiled tests may still make use of
// the macro itself in end-to-end tests.
#if canImport(LockedMacros)
import LockedMacros

let testMacros: [String: any Macro.Type] = [
    "Locked": LockedMacro.self,
]
#endif

final class LockedTests: XCTestCase {
    func testMacro() throws {
        #if canImport(LockedMacros)
        assertMacroExpansion(
            """
            """,
            expandedSource: """
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip(
            "macros are only supported when running tests for the host platform"
        )
        #endif
    }
}
