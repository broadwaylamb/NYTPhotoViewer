//
//  NYTExamplePhoto.swift
//  ios-photo-viewer
//
//  Created by Brian Capps on 2/11/15.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

import Foundation
import NYTPhotoViewer
import NYTPhotoViewerSwift

struct ExamplePhoto: PhotoProtocol {
    enum Index: Int, CaseIterable {
        case `default` = 0
        case customEverything
        case longCaption
        case defaultLoadingSpinner
        case noReferenceView
        case customMaxZoomScale
    }
    let index: Index

    // Redeclare all the properties as readwrite for sample/testing purposes.
    var state: PhotoState
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
}

extension ExamplePhoto: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.index == rhs.index
    }
}

extension ExamplePhoto: CustomStringConvertible {
    var description: String {
        "\(index)"
    }
}

extension PhotoViewerDataSource<ExamplePhoto> {
    subscript(index: ExamplePhoto.Index) -> ExamplePhoto? {
        self[index.rawValue]
    }
}
