//
//  LockedPlugin.swift
//
//  Created by Gray Campbell.
//  Copyright © 2025 Fetch.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct LockedPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        LockedMacro.self,
    ]
}
