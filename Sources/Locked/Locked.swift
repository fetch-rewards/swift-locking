//
//  Locked.swift
//  Locked
//
//  Created by Gray Campbell on 7/19/24.
//

@_exported public import LockedArguments
@_exported import os

@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Locked(_ lockType: LockType) = #externalMacro(
    module: "LockedMacros",
    type: "LockedMacro"
)
