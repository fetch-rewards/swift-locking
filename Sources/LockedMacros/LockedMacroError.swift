//
//  LockedMacroError.swift
//  LockedMacros
//
//  Created by Gray Campbell on 11/1/24.
//

import Foundation

/// An error thrown by `LockedMacro`.
enum LockedMacroError: Error, CustomStringConvertible {

    // MARK: Cases

    /// The macro was applied with an invalid ``LockType``.
    case invalidLockType

    /// The macro was applied to a declaration other than a property
    /// declaration.
    case declarationMustBeProperty

    /// The macro was applied to a property declaration with a binding specifier
    /// that is not `var`.
    case propertyDeclarationBindingSpecifierMustBeVar

    /// The macro was applied to a property declaration that does not have
    /// exactly one binding.
    case propertyDeclarationMustHaveExactlyOneBinding

    /// The macro was applied to a property declaration with a binding pattern
    /// that is not an identifier pattern.
    case bindingPatternMustBeIdentifierPattern

    /// The macro was applied to a property declaration with a binding that does
    /// not have a parsable type.
    case bindingPatternMustHaveTypeInformation

    // MARK: Properties

    var description: String {
        switch self {
        case .invalidLockType:
            "Invalid LockType."
        case .declarationMustBeProperty:
            "@Locked can only be applied to property declarations."
        case .propertyDeclarationBindingSpecifierMustBeVar:
            "@Locked property must be a var."
        case .propertyDeclarationMustHaveExactlyOneBinding:
            "@Locked property declaration must have exactly one binding."
        case .bindingPatternMustBeIdentifierPattern:
            "@Locked property declaration binding pattern must be identifier pattern."
        case .bindingPatternMustHaveTypeInformation:
            "@Locked property declaration binding must have type information."
        }
    }
}
