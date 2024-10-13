// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ApiGateway",
    products: [
        .library(
            name: "ApiGateway",
            targets: ["ApiGateway"]
        ),
    ],
    dependencies: [
        .package(name: "Api", path: "./../Api")
    ],
    targets: [
        .target(
            name: "ApiGateway",
            dependencies: [
                .product(name: "Api", package: "Api")
            ],
            path: "./"
        )
    ]
)
