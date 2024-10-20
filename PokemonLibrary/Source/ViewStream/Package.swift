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
        .package(name: "UseCase", path: "./../UseCase"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        .target(
            name: "ViewStream",
            dependencies: [
                .product(name: "UseCase", package: "UseCase"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "./"
        )
    ]
)
