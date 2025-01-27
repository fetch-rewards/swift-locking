//
//  LockTypeTests.swift
//  Locked
//
//  Created by Gray Campbell on 1/24/25.
//

#if canImport(LockedMacros)
import SwiftSyntax
import Testing
@testable import LockedMacros

struct LockTypeTests {

    // MARK: Typealiases

    typealias SUT = LockType

    // MARK: Initializer Tests

    @Test(arguments: SUT.allCases)
    func initWithValidArgument(_ lockType: SUT) throws {
        let argument = LabeledExprSyntax(
            expression: MemberAccessExprSyntax(
                name: .identifier(lockType.rawValue)
            )
        )
        let sut = try SUT(argument: argument)

        #expect(sut == lockType)
    }

    @Test
    func initWithInvalidArgument() {
        let argument = LabeledExprSyntax(
            expression: MemberAccessExprSyntax(name: "invalidLockType")
        )

        #expect(throws: SUT.ParsingError.unableToParseLockType) {
            try SUT(argument: argument)
        }
    }
}
#endif
