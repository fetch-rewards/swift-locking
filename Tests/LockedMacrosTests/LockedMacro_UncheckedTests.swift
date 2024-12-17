//
//  LockedMacro_UncheckedTests.swift
//  LockedMacrosTests
//
//  Created by Gray Campbell on 12/17/24.
//

#if canImport(LockedMacros)
import LockedMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class LockedMacro_UncheckedTests: XCTestCase {

    // MARK: Explicit Type Tests

    func testUncheckedLockWithExplicitTypeAndInitialValue() {
        assertMacroExpansion(
            """
            class Locks {
                @Locked(.unchecked)
                var count: Int = .zero
            }
            """,
            expandedSource: """
            class Locks {
                var count: Int {
                    get {
                        self._count.withLockUnchecked { count in
                            count
                        }
                    }
                    set {
                        self._count.withLockUnchecked { count in
                            count = newValue
                        }
                    }
                }
            
                private let _count = OSAllocatedUnfairLock<Int>(
                    uncheckedState: .zero
                )
            }
            """
        )
    }

    func testUncheckedLockWithExplicitTypeAndNoInitialValue() {
        assertMacroExpansion(
            """
            class Locks {
                @Locked(.unchecked)
                var count: Int
            }
            """,
            expandedSource: """
            class Locks {
                var count: Int {
                    @storageRestrictions(initializes: _count)
                    init(initialValue) {
                        self._count = OSAllocatedUnfairLock<Int>(
                            uncheckedState: initialValue
                        )
                    }
                    get {
                        self._count.withLockUnchecked { count in
                            count
                        }
                    }
                    set {
                        self._count.withLockUnchecked { count in
                            count = newValue
                        }
                    }
                }
            
                private let _count: OSAllocatedUnfairLock<Int>
            }
            """
        )
    }

    // MARK: Function Call Type Tests

    func testUncheckedLockWithFunctionCallType() {
        assertMacroExpansion(
            """
            class Locks {
                @Locked(.unchecked)
                var count = Int(1)
            }
            """,
            expandedSource: """
            class Locks {
                var count {
                    get {
                        self._count.withLockUnchecked { count in
                            count
                        }
                    }
                    set {
                        self._count.withLockUnchecked { count in
                            count = newValue
                        }
                    }
                }
            
                private let _count = OSAllocatedUnfairLock<Int>(
                    uncheckedState: Int(1)
                )
            }
            """
        )
    }

    // MARK: Member Access Type Tests

    func testUncheckedLockWithMemberAccessType() {
        assertMacroExpansion(
            """
            class Locks {
                @Locked(.unchecked)
                var count = Int.zero
            }
            """,
            expandedSource: """
            class Locks {
                var count {
                    get {
                        self._count.withLockUnchecked { count in
                            count
                        }
                    }
                    set {
                        self._count.withLockUnchecked { count in
                            count = newValue
                        }
                    }
                }
            
                private let _count = OSAllocatedUnfairLock<Int>(
                    uncheckedState: Int.zero
                )
            }
            """
        )
    }
}
#endif
