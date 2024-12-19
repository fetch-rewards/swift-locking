//
//  Locked.swift
//
//  Created by Gray Campbell.
//  Copyright © 2024 Fetch.
//

@_exported import os

@attached(accessor, names: named(init), named(get), named(set))
@attached(peer, names: prefixed(_))
public macro Locked(_ lockType: LockType) = #externalMacro(
    module: "LockedMacros",
    type: "LockedMacro"
)
