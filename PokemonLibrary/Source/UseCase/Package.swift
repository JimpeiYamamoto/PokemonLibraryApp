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
        .package(name: "ApiGateway", path: "./../ApiGateway"),
        .package(name: "Repository", path: "./../Repository"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        .target(
            name: "UseCase",
            dependencies: [
                .product(name: "ApiGateway", package: "ApiGateway"),
                .product(name: "Repository", package: "Repository"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift")
            ],
            path: "./"
        )
    ]
)
