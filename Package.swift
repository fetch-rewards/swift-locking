// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Locked",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macCatalyst(.v16),
    ],
    products: [
        .library(
            name: "Locked",
            targets: ["Locked"]
        ),
        .executable(
            name: "LockedClient",
            targets: ["LockedClient"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            exact: "600.0.0"
        ),
        .package(
            url: "git@github.com:fetch-rewards/SwiftSyntaxSugar.git",
            branch: "swift-syntax/600.0.0"
        ),
    ],
    targets: [
        .target(
            name: "Locked",
            dependencies: [
                "LockedArguments",
                "LockedMacros",
            ],
            swiftSettings: .default
        ),
        .target(
            name: "LockedArguments",
            swiftSettings: .default
        ),
        .executableTarget(
            name: "LockedClient",
            dependencies: ["Locked"],
            swiftSettings: .default
        ),
        .macro(
            name: "LockedMacros",
            dependencies: [
                "LockedArguments",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxSugar", package: "SwiftSyntaxSugar"),
            ],
            swiftSettings: .default
        ),
        .testTarget(
            name: "LockedMacrosTests",
            dependencies: [
                "LockedMacros",
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

extension Array where Element == SwiftSetting {

    /// Default Swift settings to enable for targets.
    static let `default`: [SwiftSetting] = [
        .existentialAny,
        .internalImportsByDefault,
    ]
}
