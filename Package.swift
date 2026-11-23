// swift-tools-version:5.6
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
        .target(name: "NYTPhotoViewer", path: "NYTPhotoViewer"),
    ]
)
