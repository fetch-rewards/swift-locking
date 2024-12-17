//
//  AssertMacroExpansion.swift
//  LockedMacrosTests
//
//  Created by Gray Campbell on 12/17/24.
//

// Macro implementations build for the host, so the corresponding module is not
// available when cross-compiling. Cross-compiled tests may still make use of
// the macro itself in end-to-end tests.
#if canImport(LockedMacros)
import LockedMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftSyntaxSugar

func assertMacroExpansion(
    _ originalSource: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    assertMacroExpansion(
        originalSource,
        expandedSource: expandedSource,
        diagnostics: diagnostics,
        macros: ["Locked": LockedMacro.self],
        file: file,
        line: line
    )
}
#endif
