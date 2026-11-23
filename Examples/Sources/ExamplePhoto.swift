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

final class ExamplePhoto: NSObject, NYTPhoto {
    // Redeclare all the properties as readwrite for sample/testing purposes.
    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
}
