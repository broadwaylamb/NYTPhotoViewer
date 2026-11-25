// swift-tools-version:6.4
import PackageDescription

let package = Package(
    name: "NYTPhotoViewer",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "NYTPhotoViewer", targets: ["NYTPhotoViewer"]),
    ],
    targets: [
        .target(
            name: "NYTPhotoViewer",
            path: "NYTPhotoViewer",
            resources: [
                .process("Media.xcassets"),
            ]
        )
    ]
)
