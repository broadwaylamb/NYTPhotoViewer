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
@objc(NYTPhotoViewerDataSource)
public protocol PhotoViewerDataSource: NSObjectProtocol {

    /**
     *  The total number of photos in the data source, or `nil` if the number is
     *  not known.
     *
     *  The number returned should package an `NSInteger` value.
     */
    var numberOfPhotos: NSNumber? { get } // TODO: Use `Int?` type

    /**
     *  Returns the index of a given photo, or `NSNotFound` if the photo is not in
     *  the data source.
     *
     *  @param photo The photo against which to look for the index.
     *
     *  @return The index of a given photo, or `NSNotFound` if the photo is not in
     *  the data source.
     */
    @objc(indexOfPhoto:)
    func index(of photo: any NYTPhoto) -> Int // TODO: Return `Int?`

    /**
     *  Returns the photo object at a specified index, or `nil` if one does not exist at
     *  that index.
     *
     *  @param photoIndex The index of the desired photo.
     *
     *  @return The photo object at a specified index, or `nil` if one does not exist at
     *  that index.
     */
    subscript(photoIndex: Int) -> (any NYTPhoto)? { @objc(photoAtIndex:) get }

    // TODO: Use default implementations instead of optionality
    // TODO: Use Int? instead of NSNumber
    /**
     *  The total number of interstitial views in the data source, or `nil` if the number
     *  is not known.
     *
     *  The number returned should package an `NSInteger` value.
     */
    @objc
    optional var numberOfInterstitialViews: NSNumber? { get }

    /**
     *  Indicates if the item at the specified index is a photo.
     *
     *  @return `true` if the item at the specified index is a photo, `false` otherwise.
     */
    @objc
    optional func isPhoto(atIndex idx: Int) -> Bool

    /**
     *  Indicates if the item at the specified index is an interstitial view.
     *
     *  @return `true` if the item at the specified index is an interstitial view,
     *  `false` otherwise.
     */
    @objc
    optional func isInterstitialView(atIndex idx: Int) -> Bool
}
