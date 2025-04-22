//
//  Locked_UncheckedTests.swift
//
//  Created by Gray Campbell.
//  Copyright © 2025 Fetch.
//

#if canImport(LockedMacros)
import Testing
@testable import LockedMacros

struct Locked_UncheckedTests {

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

    // MARK: Error Tests

    @Test
    func uncheckedLockWithNonPropertyDeclaration() async throws {
        let diagnostic = diagnostic(
            error: .canOnlyBeAppliedToPropertyDeclarations,
            line: 2,
            column: 5
        )

        assertMacroExpansion(
            """
            class Locks {
                @Locked(.unchecked)
                func count() {}
            }
            """,
            expandedSource: """
            class Locks {
                func count() {}
            }
            """,
            diagnostics: [
                diagnostic,
            ]
        )
    }

    @Test
    func uncheckedLockWithLetPropertyDeclaration() {
        let diagnostic = diagnostic(
            error: .canOnlyBeAppliedToPropertyDeclarationsWithVarBindingSpecifier,
            line: 2,
            column: 5
        )

        assertMacroExpansion(
            """
            class Locks {
                @Locked(.unchecked)
                let count: Int
            }
            """,
            expandedSource: """
            class Locks {
                let count: Int
            }
            """,
            diagnostics: [
                diagnostic,
                diagnostic,
            ]
        )
    }

    @Test
    func uncheckedLockWithNoTypeInformation() {
        let diagnostic = diagnostic(
            error: .unableToParseType,
            line: 2,
            column: 5
        )

        assertMacroExpansion(
            """
            class Locks {
                @Locked(.unchecked)
                var count
            }
            """,
            expandedSource: """
            class Locks {
                var count
            }
            """,
            diagnostics: [
                diagnostic,
                diagnostic,
            ]
        )
    }
}
#endif
