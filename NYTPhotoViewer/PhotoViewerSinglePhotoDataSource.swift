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
public final class PhotoViewerSinglePhotoDataSource<Photo: PhotoProtocol>: PhotoViewerDataSource {
    public let photo: Photo

    public init(photo: Photo) {
        self.photo = photo
    }

    public var numberOfPhotos: Int? {
        return 1
    }

    public subscript(photoIndex: Int) -> Photo? {
        return photo
    }

    public func index(of photo: Photo) -> Int? {
        return 0
    }
}
