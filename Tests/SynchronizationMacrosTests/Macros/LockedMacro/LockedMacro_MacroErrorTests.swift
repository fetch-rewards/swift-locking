//
//  LockedMacro_MacroErrorTests.swift
//
//  Copyright © 2025 Fetch.
//

#if canImport(SynchronizationMacros)
import Testing
@testable import SynchronizationMacros

struct LockedMacro_MacroErrorTests {

    // MARK: Typealiases

    typealias SUT = LockedMacro.MacroError

    // MARK: Description Tests

    @Test(arguments: SUT.allCases)
    func description(sut: SUT) throws {
        let expectedDescription = switch sut {
        case .canOnlyBeAppliedToPropertyDeclarations:
            "@Locked can only be applied to property declarations."
        case .canOnlyBeAppliedToPropertyDeclarationsWithVarBindingSpecifier:
            "@Locked can only be applied to `var` property declarations."
        case .canOnlyBeAppliedToSingleBindingPropertyDeclarations:
            "@Locked can only be applied to single-binding property declarations."
        case .canOnlyBeAppliedToPropertyDeclarationsWithIdentifierBindingPattern:
            """
            @Locked can only be applied to property declarations with an \ 
            identifier binding pattern.
            """
        case .unableToParseType:
            "@Locked was unable to parse a type from the property declaration's binding."
        case .noArguments:
            "@Locked was not passed any arguments."
        case .unableToParseLockTypeArgument:
            "@Locked was unable to parse the provided `lockType` argument."
        }

        #expect(sut.description == expectedDescription)
    }
}
#endif
