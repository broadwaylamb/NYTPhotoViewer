//
//  NYTPhotoViewerSinglePhotoDataSource.h
//  NYTPhotoViewer
//
//  Created by Chris Dzombak on 1/27/17.
//  Copyright © 2017 The New York Times Company. All rights reserved.
//

import Foundation

/**
 *  A simple concrete implementation of ``PhotoViewerDataSource``, for use with a single
 *  image.
 */
@objc(NYTPhotoViewerSinglePhotoDataSource)
public final class PhotoViewerSinglePhotoDataSource: NSObject, PhotoViewerDataSource {
    public let photo: any NYTPhoto

    public init(photo: any NYTPhoto) {
        self.photo = photo
    }

    public var numberOfPhotos: NSNumber? {
        return 1
    }

    public subscript(photoIndex: Int) -> (any NYTPhoto)? {
        return photo
    }

    public func index(of photo: any NYTPhoto) -> Int {
        return 0
    }
}
