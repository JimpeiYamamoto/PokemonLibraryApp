// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ViewStream",
    products: [
        .library(
            name: "ViewStream",
            targets: ["ViewStream"]
        ),
    ],
    dependencies: [
        .package(name: "UseCase", path: "./../UseCase")
    ],
    targets: [
        .target(
            name: "ViewStream",
            dependencies: [
                .product(name: "UseCase", package: "UseCase")
            ],
            path: "./"
        )
    ]
)
