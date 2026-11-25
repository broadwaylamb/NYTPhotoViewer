//
//  NYTPhotosViewControllerDataSource.h
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/10/15.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

import UIKit

/**
 *  The data source for an ``NYTPhotosViewController`` instance.
 *
 *  A view controller, view model, or model in your application could conform to this
 *  protocol, depending on what makes sense in your architecture.
 *
 *  Alternatively, `NYTPhotoViewerArrayDataSource` and
 *  `NYTPhotoViewerSinglePhotoDataSource` are concrete classes which conveniently handle
 *  the most common use cases for NYTPhotoViewer.
 */
public protocol PhotoViewerDataSource: AnyObject {

    /**
     *  The total number of photos in the data source, or `nil` if the number is
     *  not known.
     */
    var numberOfPhotos: Int? { get }

    /**
     *  Returns the index of a given photo, or `NSNotFound` if the photo is not in
     *  the data source.
     *
     *  @param photo The photo against which to look for the index.
     *
     *  @return The index of a given photo, or `nil if the photo is not in
     *  the data source.
     */
    func index(of photo: any NYTPhoto) -> Int?

    /**
     *  Returns the photo object at a specified index, or `nil` if one does not exist at
     *  that index.
     *
     *  @param photoIndex The index of the desired photo.
     *
     *  @return The photo object at a specified index, or `nil` if one does not exist at
     *  that index.
     */
    subscript(photoIndex: Int) -> (any NYTPhoto)? { get }

    /**
     *  The total number of interstitial views in the data source, or `nil` if the number
     *  is not known.
     *
     *  The number returned should package an `NSInteger` value.
     */
    var numberOfInterstitialViews: Int? { get }

    /**
     *  Indicates if the item at the specified index is a photo.
     *
     *  @return `true` if the item at the specified index is a photo, `false` otherwise.
     */
    func isPhoto(atIndex idx: Int) -> Bool

    /**
     *  Indicates if the item at the specified index is an interstitial view.
     *
     *  @return `true` if the item at the specified index is an interstitial view,
     *  `false` otherwise.
     */
    func isInterstitialView(atIndex idx: Int) -> Bool
}

extension PhotoViewerDataSource {
    public var numberOfInterstitialViews: Int? { nil }

    public func isPhoto(atIndex idx: Int) -> Bool {
        true
    }

    /**
     *  Indicates if the item at the specified index is an interstitial view.
     *
     *  @return `true` if the item at the specified index is an interstitial view,
     *  `false` otherwise.
     */
    public func isInterstitialView(atIndex idx: Int) -> Bool {
        false
    }
}
