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
 *  of images.
 */
public final class PhotoViewerArrayDataSource<Photo: PhotoProtocol>: PhotoViewerDataSource {
    public var photos: [Photo]

    public init(photos: [Photo] = []) {
        self.photos = photos
    }

    public var numberOfPhotos: Int? {
        return photos.count
    }

    public subscript(photoIndex: Int) -> Photo? {
        if photoIndex < photos.count {
            return photos[photoIndex]
        }

        return nil
    }

    public func index(of photo: Photo) -> Int? {
        photos.firstIndex(of: photo)
    }
}
