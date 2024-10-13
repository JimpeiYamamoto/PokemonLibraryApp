// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Api",
    products: [
        .library(
            name: "Api",
            targets: ["Api"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Api",
            dependencies: [
            ],
            path: "./"
        )
    ]
)
