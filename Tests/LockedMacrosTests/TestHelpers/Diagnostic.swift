//
//  Diagnostic.swift
//  Locked
//
//  Created by Gray Campbell on 12/18/24.
//

#if canImport(LockedMacros)
import SwiftDiagnostics
import SwiftSyntaxMacrosGenericTestSupport
@testable import LockedMacros

func diagnostic(
    id: MessageID? = nil,
    error: LockedMacroError,
    line: Int,
    column: Int,
    severity: DiagnosticSeverity = .error,
    highlights: [String]? = nil,
    notes: [NoteSpec] = [],
    fixIts: [FixItSpec] = [],
    originatorFileID: StaticString = #fileID,
    originatorFile: StaticString = #filePath,
    originatorLine: UInt = #line,
    originatorColumn: UInt = #column
) -> DiagnosticSpec {
    DiagnosticSpec(
        id: id,
        message: error.description,
        line: line,
        column: column,
        severity: severity,
        highlights: highlights,
        notes: notes,
        fixIts: fixIts,
        originatorFileID: originatorFileID,
        originatorFile: originatorFile,
        originatorLine: originatorLine,
        originatorColumn: originatorColumn
    )
}
#endif
