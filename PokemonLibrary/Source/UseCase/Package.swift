// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "UseCase",
    products: [
        .library(
            name: "UseCase",
            targets: ["UseCase"]
        ),
    ],
    dependencies: [
        .package(name: "ApiGateway", path: "./../ApiGateway")
    ],
    targets: [
        .target(
            name: "UseCase",
            dependencies: [
                .product(name: "ApiGateway", package: "ApiGateway")
            ],
            path: "./"
        )
    ]
)
