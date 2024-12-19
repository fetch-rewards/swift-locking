//
//  LockedMacroErrorTests.swift
//  LockedMacrosTests
//
//  Created by Gray Campbell on 12/19/24.
//

#if canImport(LockedMacros)
import Testing
@testable import LockedMacros

struct LockedMacroErrorTests {

    // MARK: Typealiases

    typealias SUT = LockedMacroError

    // MARK: Description Tests

    @Test(arguments: SUT.allCases)
    func description(sut: SUT) throws {
        let expectedDescription = switch sut {
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

        #expect(sut.description == expectedDescription)
    }
}
#endif
