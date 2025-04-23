// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-synchronization",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macCatalyst(.v16),
    ],
    products: [
        .library(
            name: "Synchronization",
            targets: ["Synchronization"]
        ),
        .executable(
            name: "SynchronizationClient",
            targets: ["SynchronizationClient"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            exact: "600.0.0"
        ),
        .package(
            url: "https://github.com/fetch-rewards/SwiftSyntaxSugar.git",
            exact: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "Synchronization",
            dependencies: ["SynchronizationMacros"],
            swiftSettings: .default
        ),
        .executableTarget(
            name: "SynchronizationClient",
            dependencies: ["Synchronization"],
            swiftSettings: .default
        ),
        .macro(
            name: "SynchronizationMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxSugar", package: "SwiftSyntaxSugar"),
            ],
            swiftSettings: .default
        ),
        .testTarget(
            name: "SynchronizationMacrosTests",
            dependencies: [
                "SynchronizationMacros",
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
