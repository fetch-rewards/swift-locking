//
//  AssertMacroExpansion.swift
//
//  Created by Gray Campbell.
//  Copyright © 2025 Fetch.
//

// Macro implementations build for the host, so the corresponding module is not
// available when cross-compiling. Cross-compiled tests may still make use of
// the macro itself in end-to-end tests.
#if canImport(LockedMacros)
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import LockedMacros

func assertMacroExpansion(
    _ originalSource: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    applyFixIts: [String]? = nil,
    fixedSource: String? = nil,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    assertMacroExpansion(
        originalSource,
        expandedSource: expandedSource,
        diagnostics: diagnostics,
        macroSpecs: ["Locked": MacroSpec(type: LockedMacro.self)],
        applyFixIts: applyFixIts,
        fixedSource: fixedSource,
        failureHandler: { testFailure in
            Issue.record(
                "\(testFailure.message)",
                sourceLocation: SourceLocation(
                    fileID: testFailure.location.fileID,
                    filePath: testFailure.location.filePath,
                    line: testFailure.location.line,
                    column: testFailure.location.column
                )
            )
        },
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}
#endif
