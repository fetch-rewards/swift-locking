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

        #expect {
            try SUT(argument: argument)
        } throws: { error in
            let parsingError = try #require(error as? SUT.ParsingError)

            return parsingError == .unableToParseLockType
        }
    }
}
#endif
