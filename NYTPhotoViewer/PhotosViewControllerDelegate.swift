//
//  PhotosViewController.swift
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/10/15.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

import UIKit

/**
 *  A protocol of entirely optional methods called for view-related configuration and
 *  lifecycle events by an ``PhotosViewController`` instance.
 */
public protocol PhotosViewControllerDelegate<Photo>: AnyObject {

    associatedtype Photo: NYTPhoto

    /**
     *  Called when a new photo is displayed through a swipe gesture.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param photo                The photo object that was just displayed.
     *  @param photoIndex           The index of the photo that was just displayed.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        didNavigateTo photo: Photo,
        atIndex photoIndex: Int
    )

    /**
     *  Called when a new interstitial view is displayed through a swipe gesture.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param view                 The view that was just displayed.
     *  @param index                The index of the view that was just displayed.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        didNavigateToInterstialView view: UIView,
        atIndex index: Int
    )

    /**
     *  Called immediately before the ``PhotosViewController`` is about to start
     *  a user-initiated dismissal.
     *  This will be the beginning of the interactive panning to dismiss, if it is enabled
     *  and performed.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     */
    func photosViewControllerWillDismiss(
        _ photosViewController: PhotosViewController<Photo>
    )

    /**
     *  Called immediately after the photos view controller has been dismissed by
     *  the user.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *  the delegate message.
     */
    func photosViewControllerDidDismiss(
        _ photosViewController: PhotosViewController<Photo>
    )

    /**
     *  Returns a view to display over a photo, full width, locked to the bottom,
     *  representing the caption for the photo.
     *
     *  Can be any `UIView` object, but the view returned is expected to respond to
     *  `intrinsicContentSize` appropriately to calculate height.
     *
     *  @note Your implementation can get caption information from the appropriate
     *        properties on the given `NYTPhoto`.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param photo                The photo object over which to display the caption
     *                              view.
     *
     *  @return A view to display as the caption for the photo.
     *          Return `nil` to show a default view generated from the caption properties
     *          on the photo object.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        captionViewFor photo: Photo
    ) -> UIView?

    /**
     *  Returns whether the caption view should respect the safe area.
     *
     * @note If this method is not implemented it will default to `true`.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param photo                The photo object over which to display the caption
     *                              view.
     *
     *  @return A `Bool` indicating whether the caption view should respect the safe area
     *  for the given photo or not.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        captionViewRespectsSafeAreaFor photo: Photo
    ) -> Bool

    /**
     *  Returns a string to display as the title in the navigation-bar area for a photo.
     *
     *  This small area of the screen is not intended to display a caption or similar
     *  information about the photo itself. (NYTPhotoViewer is designed to provide this
     *  information in the caption view, and as such the `NYTPhoto` protocol provides
     *  properties for a title, summary, and credit for each photo.) Instead, consider
     *  using this delegate method to customize how your app displays the user's progress
     *  through a set of photos.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param photo                The photo object for which to display the title.
     *  @param photoIndex           The index of the photo.
     *  @param totalPhotoCount      The number of photos being displayed by the photo
     *                              viewer, or `nil` if the total number of photos is not
     *                              known.
     *
     *  @return The text to display as the navigation-item title for the given photo.
     *  Return `nil` to show a default title like "1 of 4" indicating progress in
     *  a slideshow, or an empty string to hide this text entirely.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        titleFor photo: Photo,
        atIndex photoIndex: Int,
        totalPhotoCount: Int?
    ) -> String?

    /**
     *  Returns a view to display while a photo is loading. Can be any `UIView` object,
     *  but is expected to respond to `sizeToFit` appropriately. This view will be sized
     *  and centered in the blank area, and hidden when the photo image or its placeholder
     *  is loaded.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param photo                The photo object over which to display the activity
     *                              view.
     *
     *  @return A view to display while the photo is loading.
     *  Return `nil` to show a default medium `UIActivityIndicatorView`.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        loadingViewFor photo: Photo
    ) -> UIView?

    /**
     *  Returns the view from which to animate for a given object conforming to
     *  the `NYTPhoto` protocol.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param photo                The photo for which the animation will occur.
     *
     *  @return The view to animate out of or into for the given photo.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        referenceViewFor photo: Photo
    ) -> UIView?

    /**
     *  Returns the maximum zoom scale for a given object conforming to the `NYTPhoto`
     *  protocol.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param photo                The photo for which the maximum zoom scale is
     *                              requested.
     *
     *  @return The maximum zoom scale for the given photo.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        maximumZoomScaleFor photo: Photo
    ) -> CGFloat?

    /**
     *  Called when a photo is long pressed.
     *
     *  @param photosViewController       The ``PhotosViewController`` instance that sent
     *                                    the delegate message.
     *  @param photo                      The photo being displayed that was long pressed.
     *  @param longPressGestureRecognizer The gesture recognizer that detected the long
     *                                    press.
     *
     *  @return `true` if the long press was handled by the client, `false` if the default
     *  `UIMenuController` with a Copy action is desired.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        handleLongPressFor photo: Photo,
        withGestureRecognizer longPressGestureRecognizer: UILongPressGestureRecognizer
    ) -> Bool

    /**
     *  Called when the action button is tapped.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param photo                The photo being displayed when the action button was
     *                              tapped.
     *
     *  @return `true` if the action button tap was handled by the client, `false` if
     *  the default `UIActivityViewController` is desired.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        handleActionButtonTappedFor photo: Photo
    ) -> Bool

    /**
     *  Called after the default `UIActivityViewController` is presented and successfully
     *  completes an action with a specified activity type.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param activityType         The activity type that was successfully shared.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        actionCompletedWithActivityType activityType: UIActivity.ActivityType
    )

    /**
     *  Called when an ``InterstitialViewController`` is created but before it is
     *  displayed. Returns the view to display as an interstitial view.
     *
     *  @param photosViewController The ``PhotosViewController`` instance that sent
     *                              the delegate message.
     *  @param index                The index in the page view controller where the view
     *                              will be displayed.
     *
     *  @return A `UIView`.
     */
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        interstitialViewAtIndex index: Int
    ) -> UIView?
}

extension PhotosViewControllerDelegate {
    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        didNavigateTo photo: Photo,
        atIndex photoIndex: Int
    ) {}

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        didNavigateToInterstialView view: UIView,
        atIndex index: Int
    ) {}

    func photosViewControllerWillDismiss(
        _ photosViewController: PhotosViewController<Photo>
    ) {}

    func photosViewControllerDidDismiss(
        _ photosViewController: PhotosViewController<Photo>
    ) {}

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        captionViewFor photo: Photo
    ) -> UIView? {
        nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        captionViewRespectsSafeAreaFor photo: Photo
    ) -> Bool {
        true
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        titleFor photo: Photo,
        atIndex photoIndex: Int,
        totalPhotoCount: Int?
    ) -> String? {
        nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        loadingViewFor photo: Photo
    ) -> UIView? {
        nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        referenceViewFor photo: Photo
    ) -> UIView? {
        nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        maximumZoomScaleFor photo: Photo
    ) -> CGFloat? {
        nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        handleLongPressFor photo: Photo,
        withGestureRecognizer longPressGestureRecognizer: UILongPressGestureRecognizer
    ) -> Bool {
        false
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        handleActionButtonTappedFor photo: Photo
    ) -> Bool {
        false
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        actionCompletedWithActivityType activityType: UIActivity.ActivityType
    ) {}

    func photosViewController(
        _ photosViewController: PhotosViewController<Photo>,
        interstitialViewAtIndex index: Int
    ) -> UIView? {
        nil
    }
}
