//
//  LockedMacro_UncheckedTests.swift
//  LockedMacrosTests
//
//  Created by Gray Campbell on 12/17/24.
//

#if canImport(LockedMacros)
import LockedMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

struct LockedMacro_UncheckedTests {

    // MARK: Explicit Type Tests

    @Test
    func uncheckedLockWithExplicitTypeAndInitialValue() {
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

    @Test
    func uncheckedLockWithExplicitTypeAndNoInitialValue() {
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

    @Test
    func uncheckedLockWithFunctionCallType() {
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

    @Test
    func uncheckedLockWithMemberAccessType() {
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
