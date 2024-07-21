//
//  Locked.swift
//  Locked
//
//  Created by Gray Campbell on 7/19/24.
//

@_exported import LockedArguments

@attached(accessor)
@attached(peer, names: prefixed(_))
package macro Locked(_ lockType: LockType) = #externalMacro(
    module: "LockedMacros",
    type: "LockedMacro"
)
