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
        .package(name: "Api", path: "./../Api"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        .target(
            name: "ApiGateway",
            dependencies: [
                .product(name: "Api", package: "Api"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift")
            ],
            path: "./"
        )
    ]
)
