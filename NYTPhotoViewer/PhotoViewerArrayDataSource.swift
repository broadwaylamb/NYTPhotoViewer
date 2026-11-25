//
//  NYTPhotoViewerArrayDataSource.h
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/11/15.
//  Copyright (c) 2017 The New York Times Company. All rights reserved.
//

import Foundation


/**
 *  A simple concrete implementation of ``PhotoViewerDataSource``, for use with an array
 *  of images. Does not support interstitial views.
 */
public final class PhotoViewerArrayDataSource: NSObject, PhotoViewerDataSource {
    public let photos: [any NYTPhoto]

    public init(photos: [any NYTPhoto] = []) {
        self.photos = photos
    }

    public var numberOfPhotos: Int? {
        return photos.count
    }

    public subscript(photoIndex: Int) -> (any NYTPhoto)? {
        if photoIndex < photos.count {
            return photos[photoIndex]
        }

        return nil
    }

    public func index(of photo: any NYTPhoto) -> Int? {
        // TODO: Use Equatable
        return photos.firstIndex { $0.isEqual(photo) }
    }
}
