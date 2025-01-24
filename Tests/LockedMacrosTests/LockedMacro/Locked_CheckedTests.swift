//
//  Locked_CheckedTests.swift
//
//  Created by Gray Campbell.
//  Copyright © 2024 Fetch.
//

#if canImport(LockedMacros)
import Testing
@testable import LockedMacros

struct Locked_CheckedTests {

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

    // MARK: Error Tests

    @Test
    func checkedLockWithNonPropertyDeclaration() async throws {
        let diagnostic = diagnostic(
            error: .canOnlyBeAppliedToPropertyDeclarations,
            line: 2,
            column: 5
        )

        assertMacroExpansion(
            """
            class Locks {
                @Locked(.checked)
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
    func checkedLockWithLetPropertyDeclaration() {
        let diagnostic = diagnostic(
            error: .canOnlyBeAppliedToPropertyDeclarationsWithVarBindingSpecifier,
            line: 2,
            column: 5
        )

        assertMacroExpansion(
            """
            class Locks {
                @Locked(.checked)
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
    func checkedLockWithNoTypeInformation() {
        let diagnostic = diagnostic(
            error: .unableToParseType,
            line: 2,
            column: 5
        )

        assertMacroExpansion(
            """
            class Locks {
                @Locked(.checked)
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
