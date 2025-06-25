// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-locking",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macCatalyst(.v16),
    ],
    products: [
        .library(
            name: "Locking",
            targets: ["Locking"]
        ),
        .executable(
            name: "LockingClient",
            targets: ["LockingClient"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            exact: "600.0.0" // Must match SwiftSyntaxSugar's swift-syntax version
        ),
        .package(
            url: "https://github.com/fetch-rewards/SwiftSyntaxSugar.git",
            exact: "0.1.1"
        ),
    ],
    targets: [
        .target(
            name: "Locking",
            dependencies: ["LockingMacros"],
            swiftSettings: .default
        ),
        .executableTarget(
            name: "LockingClient",
            dependencies: ["Locking"],
            swiftSettings: .default
        ),
        .macro(
            name: "LockingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxSugar", package: "SwiftSyntaxSugar"),
            ],
            swiftSettings: .default
        ),
        .testTarget(
            name: "LockingMacrosTests",
            dependencies: [
                "LockingMacros",
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                ),
            ],
            swiftSettings: .default
        ),
    ]
)

// MARK: - Swift Settings

extension SwiftSetting {
    static let existentialAny: SwiftSetting = .enableUpcomingFeature(
        "ExistentialAny"
    )

    static let internalImportsByDefault: SwiftSetting = .enableUpcomingFeature(
        "InternalImportsByDefault"
    )
}

extension [SwiftSetting] {

    /// Default Swift settings to enable for targets.
    static let `default`: [SwiftSetting] = [
        .existentialAny,
        .internalImportsByDefault,
    ]
}
