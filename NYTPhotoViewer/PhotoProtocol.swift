//
//  PhotoProtocol.swift
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/10/15.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

import UIKit

/**
 *  The model for photos displayed in an ``PhotosViewController``.
 *
 *  Your models should implement `==` to provide a concept of identity for the PhotoViewer
 *  to work with.
 */
public protocol PhotoProtocol: Equatable {

    /**
     *  The image to display, or a placeholder image for display while the image
     *  is loading.
     */
    var state: PhotoState { get }

    // MARK: Caption

    /**
     *  An attributed string for display as the title of the caption.
     */
    var attributedCaptionTitle: NSAttributedString? { get }

    /**
     *  An attributed string for display as the summary of the caption.
     */
    var attributedCaptionSummary: NSAttributedString? { get }

    /**
     *  An attributed string for display as the credit of the caption.
     */
    var attributedCaptionCredit: NSAttributedString? { get }
}

public enum PhotoState: Equatable, Hashable, Sendable {
    case loaded(UIImage)
    case placeholder(UIImage)
    case none

    var image: UIImage? {
        switch self {
        case .loaded(let image), .placeholder(let image):
            image
        case .none:
            nil
        }
    }
}
