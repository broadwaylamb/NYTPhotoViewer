//
//  NYTPhoto.h
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/10/15.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

import UIKit

/**
 *  The model for photos displayed in an ``NYTPhotosViewController``.
 *
 *  Your models (or boxes, if working with Swift value types) should override `isEqual:`
 *  to provide a concept of identity for the PhotoViewer to work with.
 */
@objc
public protocol NYTPhoto: NSObjectProtocol {

    /**
     *  The image to display.
     */
    var image: UIImage? { get } // TODO: Make non-optional

    /**
     *  A placeholder image for display while the image is loading.
     *
     *  This property is used if and only if ``imageData`` and ``image`` return `nil`.
     */
    var placeholderImage: UIImage? { get }

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
