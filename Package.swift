// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "NYTPhotoViewer",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "NYTPhotoViewer", targets: ["NYTPhotoViewer", "NYTPhotoViewerSwift"]),
    ],
    targets: [
        .target(
            name: "NYTPhotoViewer",
            dependencies: ["NYTPhotoViewerSwift"],
            path: "NYTPhotoViewer",
            exclude: [
                "NYTPhoto.swift",
                "PhotoViewerDataSource.swift",
                "PhotoViewerSinglePhotoDataSource.swift",
            ],
        ),
        .target(
            name: "NYTPhotoViewerSwift",
            path: "NYTPhotoViewer",
            sources: [
                "NYTPhoto.swift",
                "PhotoViewerDataSource.swift",
                "PhotoViewerSinglePhotoDataSource.swift",
            ],
        )
    ]
)
