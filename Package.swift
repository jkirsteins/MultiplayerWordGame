// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Crossy Word",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "Crossy Word",
            targets: ["AppModule"],
            bundleIdentifier: "org.janiskirsteins.MultiplayerWordGame",
            teamIdentifier: "FN5YR78T7X",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
additionalInfoPlistContentFilePath: "MoreInfo.plist"
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
exclude: ["./MoreInfo.plist"],
resources: [ .process("Resources")]
        )
    ]
)
