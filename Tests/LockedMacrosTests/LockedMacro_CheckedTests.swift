//
//  LockedMacro_CheckedTests.swift
//  LockedMacrosTests
//
//  Created by Gray Campbell on 12/17/24.
//

#if canImport(LockedMacros)
import LockedMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

struct LockedMacro_CheckedTests {

    // MARK: Explicit Type Tests

    @Test
    func checkedLockWithExplicitTypeAndInitialValue() {
        assertMacroExpansion(
            """
            class Locks {
                @Locked(.checked)
                var count: Int = .zero
            }
            """,
            expandedSource: """
            class Locks {
                var count: Int {
                    get {
                        self._count.withLock { count in
                            count
                        }
                    }
                    set {
                        self._count.withLock { count in
                            count = newValue
                        }
                    }
                }
            
                private let _count = OSAllocatedUnfairLock<Int>(
                    initialState: .zero
                )
            }
            """
        )
    }

    @Test
    func checkedLockWithExplicitTypeAndNoInitialValue() {
        assertMacroExpansion(
            """
            class Locks {
                @Locked(.checked)
                var count: Int
            }
            """,
            expandedSource: """
            class Locks {
                var count: Int {
                    @storageRestrictions(initializes: _count)
                    init(initialValue) {
                        self._count = OSAllocatedUnfairLock<Int>(
                            initialState: initialValue
                        )
                    }
                    get {
                        self._count.withLock { count in
                            count
                        }
                    }
                    set {
                        self._count.withLock { count in
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

    @Test
    func checkedLockWithFunctionCallType() {
        assertMacroExpansion(
            """
            class Locks {
                @Locked(.checked)
                var count = Int(1)
            }
            """,
            expandedSource: """
            class Locks {
                var count {
                    get {
                        self._count.withLock { count in
                            count
                        }
                    }
                    set {
                        self._count.withLock { count in
                            count = newValue
                        }
                    }
                }
            
                private let _count = OSAllocatedUnfairLock<Int>(
                    initialState: Int(1)
                )
            }
            """
        )
    }

    // MARK: Member Access Type Tests

    @Test
    func checkedLockWithMemberAccessType() {
        assertMacroExpansion(
            """
            class Locks {
                @Locked(.checked)
                var count = Int.zero
            }
            """,
            expandedSource: """
            class Locks {
                var count {
                    get {
                        self._count.withLock { count in
                            count
                        }
                    }
                    set {
                        self._count.withLock { count in
                            count = newValue
                        }
                    }
                }
            
                private let _count = OSAllocatedUnfairLock<Int>(
                    initialState: Int.zero
                )
            }
            """
        )
    }
}
#endif
