//
//  Locked.swift
//  Locked
//
//  Created by Gray Campbell on 7/19/24.
//

@attached(accessor)
@attached(peer, names: prefixed(_))
package macro Locked() = #externalMacro(
    module: "LockedMacros",
    type: "LockedMacro"
)
