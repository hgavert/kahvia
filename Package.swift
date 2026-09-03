// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Kahvia",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Kahvia",
            path: "Sources",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"]),
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
            ]
        ),
    ]
)
