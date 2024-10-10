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
            from: "600.0.1"
        ),
        .package(
            url: "git@github.com:fetch-rewards/SwiftSyntaxSugar.git",
            revision: "77515ef993aa129ef2febe0f5c9c96e549e9168a"
        ),
    ],
    targets: [
        .target(
            name: "Locked",
            dependencies: ["LockedMacros"],
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
    static let internalImportsByDefault: SwiftSetting = .enableUpcomingFeature("InternalImportsByDefault")
    static let existentialAny: SwiftSetting = .enableUpcomingFeature("ExistentialAny")
}

extension Array where Element == SwiftSetting {

    /// Default Swift settings to enable for targets.
    static let `default`: [SwiftSetting] = [
        .internalImportsByDefault,
        .existentialAny,
    ]
}
