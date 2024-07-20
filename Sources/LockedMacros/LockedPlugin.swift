//
//  LockedPlugin.swift
//  LockedMacros
//
//  Created by Gray Campbell on 7/20/24.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct LockedPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        LockedMacro.self,
    ]
}
