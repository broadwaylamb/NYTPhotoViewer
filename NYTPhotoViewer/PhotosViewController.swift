//
//  PhotosViewController.swift
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/10/15.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

import UIKit
import LinkPresentation

public final class PhotosViewController<Photo: NYTPhoto>
    : UIViewController,
      UIPageViewControllerDataSource,
      UIPageViewControllerDelegate,
      UIActivityItemSource
{
    private static var overlayAnimationDuration: CGFloat { 0.2 }
    private static var interPhotoSpacing: CGFloat { 16 }
    private static var closeButtonImageInsets: UIEdgeInsets {
        UIEdgeInsets(top: 3, left: 0, bottom: -3, right: 0)
    }

    /**
     *  The internal page view controller used for swiping horizontally, photo to photo.
     */
    public let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: [.interPageSpacing : interPhotoSpacing]
    )

    private let transitionController = PhotoTransitionController()

    /**
     *  The pan gesture recognizer used for panning to dismiss the photo.
     *  Disable to stop the pan-to-dismiss behavior.
     */
    public private(set) lazy var panGestureRecognizer =
        UIPanGestureRecognizer(target: self, action: #selector(didPan))

    /**
     *  The tap gesture recognizer used to hide the overlay, including the caption,
     *  left and right bar button items, and title, all at once.
     *  Disable to always show the overlay.
     */
    public private(set) lazy var singleTapGestureRecognizer =
        UITapGestureRecognizer(target: self, action: #selector(didSingleTap))

    /**
     *  The overlay view displayed over photos.
     */
    public let overlayView = PhotosOverlayView()

    /// A custom notification center to scope internal notifications to this
    /// ``PhotosViewController`` instance.
    private let notificationCenter = NotificationCenter()

    private var shouldHandleLongPress = false

    private var overlayWasHiddenBeforeTransition = false

    private var initialPhoto: Photo?

    /**
     *  The data source underlying this ``PhotosViewController``.
     *
     *  After setting a new data source, you must call ``reloadPhotosAnimated``.
     */
    public weak var dataSource: (any PhotoViewerDataSource<Photo>)?

    /**
     *  The object that acts as the delegate of the ``PhotosViewController``.
     */
    public weak var delegate: (any PhotosViewControllerDelegate<Photo>)?

    deinit {
        pageViewController.dataSource = nil
        pageViewController.delegate = nil
    }

    // MARK: - NSObject(UIResponderStandardEditActions)

    public override func copy(_ sender: Any?) {
        if case .loaded(let image) = currentlyDisplayedPhoto?.state {
            UIPasteboard.general.image = image
        }
    }

    // MARK: - UIResponder
    public override var canBecomeFirstResponder: Bool {
        true
    }

    public override func canPerformAction(
        _ action: Selector,
        withSender sender: Any?
    ) -> Bool {
        if shouldHandleLongPress,
           action == #selector(copy(_:)),
           case .loaded = currentlyDisplayedPhoto?.state
        {
            return true
        }

        return false
    }

    // MARK: - UIViewController

    public override convenience init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        self.init(dataSource: PhotoViewerArrayDataSource())
    }

    required convenience init?(coder: NSCoder) {
        self.init(dataSource: PhotoViewerArrayDataSource())
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configurePageViewControllerWithInitialPhoto()

        view.tintColor = .white
        view.backgroundColor = .black
        pageViewController.view.backgroundColor = .clear

        pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        pageViewController.view.addGestureRecognizer(singleTapGestureRecognizer)

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        addOverlayView()

        transitionController.startingView = referenceViewForCurrentPhoto;

        if currentlyDisplayedPhoto?.state.image != nil {
            transitionController.endingView =
                currentPhotoViewController?.scalingImageView.imageView
        } else {
            transitionController.endingView = nil
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !overlayWasHiddenBeforeTransition {
            setOverlayView(hidden: false, animated: true)
        }
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        pageViewController.view.frame = view.bounds
        overlayView.frame = view.bounds
    }

    public override var prefersStatusBarHidden: Bool {
        true
    }

    public override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }

    public override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        dismiss(animated: flag, userInitiated: false, completion: completion)
    }

    // MARK: - NYTPhotosViewController

    /**
     *  Initializes a ``PhotosViewController`` with the given data source and delegate,
     *  initially displaying the photo at the given index in the data source.
     *
     *  @param dataSource        The data source underlying this photo viewer.
     *  @param initialPhotoIndex The photo to display initially. If outside the bounds of
     *                           the data source, the first photo from the data source
     *                           will be displayed.
     *  @param delegate          The delegate for this ``PhotosViewController``.
     */
    public init(
        dataSource: any PhotoViewerDataSource<Photo>,
        initialPhotoIndex: Int = 0,
        delegate: (any PhotosViewControllerDelegate<Photo>)? = nil,
    ) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.initialPhoto = dataSource[initialPhotoIndex]

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
        transitioningDelegate = transitionController;
        modalPresentationCapturesStatusBarAppearance = true

        let leftBarButtonItem = UIBarButtonItem(
            image: UIImage(resource: .nytPhotoViewerCloseButtonX),
            style: .plain,
            target: self,
            action: #selector(doneButtonTapped)
        )
        overlayView.leftBarButtonItem = leftBarButtonItem
        leftBarButtonItem.imageInsets = Self.closeButtonImageInsets
        leftBarButtonItem.tintColor = .white

        let rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(actionButtonTapped)
        )
        overlayView.rightBarButtonItem = rightBarButtonItem
        rightBarButtonItem.tintColor = .white

        pageViewController.delegate = self;
        pageViewController.dataSource = self;
    }

    private func configurePageViewControllerWithInitialPhoto() {
        guard let dataSource else { return }

        let initialPhotoViewController: PhotoViewController<Photo>? =
            if let initialPhoto,
               let initialPhotoIndex = dataSource.index(of: initialPhoto)
            {
                newPhotoViewController(for: initialPhoto, atIndex: initialPhotoIndex)
            } else if let initialPhoto = dataSource[0] {
                newPhotoViewController(for: initialPhoto, atIndex: 0)
            } else {
                nil
            }

        if let initialPhotoViewController {
            setCurrentlyDisplayedViewController(
                initialPhotoViewController,
                animated: false
            )
        }
    }

    private func addOverlayView() {
        let textColor = view.tintColor ?? .white
        overlayView.titleTextAttributes = [.foregroundColor : textColor]

        updateOverlayInformation()
        view.addSubview(overlayView)

        setOverlayView(hidden: true, animated: false)
    }

    private func updateOverlayInformation() {
        guard let currentlyDisplayedPhoto,
              let photoIndex = currentPhotoViewController?.photoViewItemIndex
        else {
            return
        }
        let displayIndex = photoIndex + 1

        var overlayTitle = delegate?
            .photosViewController(
                self,
                titleFor: currentlyDisplayedPhoto,
                atIndex: photoIndex,
                totalPhotoCount: dataSource?.numberOfPhotos
            )

        if overlayTitle == nil && dataSource?.numberOfPhotos == nil {
            overlayTitle = String(localized: "\(displayIndex)")
        }

        let totalItems = totalItemCount
        if overlayTitle == nil && totalItems > 1 {
            overlayTitle = String(localized: "\(displayIndex) of \(totalItems)")
        }

        overlayView.title = overlayTitle

        overlayView.captionView = delegate?
            .photosViewController(self, captionViewFor: currentlyDisplayedPhoto)
            ?? PhotoCaptionView(
                attributedTitle: currentlyDisplayedPhoto.attributedCaptionTitle,
                attributedSummary: currentlyDisplayedPhoto.attributedCaptionSummary,
                attributedCredit: currentlyDisplayedPhoto.attributedCaptionCredit
            )

        overlayView.captionViewRespectsSafeArea = delegate?.photosViewController(
            self,
            captionViewRespectsSafeAreaFor: currentlyDisplayedPhoto
        ) ?? true
    }

    @objc
    private func doneButtonTapped(_ sender: Any?) {
        dismiss(animated: true, userInitiated: true)
    }

    @objc
    private func actionButtonTapped(_ sender: UIBarButtonItem) {
        guard let currentlyDisplayedPhoto else { return }

        let clientDidHandle = delegate?.photosViewController(
            self,
            handleActionButtonTappedFor: currentlyDisplayedPhoto
        ) ?? false

        if !clientDidHandle, case .loaded(let image) = currentlyDisplayedPhoto.state {
            let activityViewController = UIActivityViewController(
                activityItems: [self, image],
                applicationActivities: nil
            )
            activityViewController.popoverPresentationController?.barButtonItem = sender
            activityViewController.completionWithItemsHandler =
                { activityType, completed, returnedItems, activityError in
                    if completed, let activityType {
                        self.delegate?.photosViewController(
                            self,
                            actionCompletedWithActivityType: activityType
                        )
                    }
                }

            present(activityViewController, animated: true)
        }
    }

    /**
     *  The left bar button item overlaying the photo.
     */
    public var leftBarButtonItem: UIBarButtonItem? {
        get {
            overlayView.leftBarButtonItem
        }
        set {
            overlayView.leftBarButtonItem = newValue
        }
    }

    public var leftBarButtonItems: [UIBarButtonItem]? {
        get {
            overlayView.leftBarButtonItems
        }
        set {
            overlayView.leftBarButtonItems = newValue
        }
    }

    /**
     *  The right bar button item overlaying the photo.
     */
    public var rightBarButtonItem: UIBarButtonItem? {
        get {
            overlayView.rightBarButtonItem
        }
        set {
            overlayView.rightBarButtonItem = newValue
        }
    }

    public var rightBarButtonItems: [UIBarButtonItem]? {
        get {
            overlayView.rightBarButtonItems
        }
        set {
            overlayView.rightBarButtonItems = newValue
        }
    }

    /**
     *  Displays the specified photo. Can be called before the view controller is
     *  displayed. Calling with a photo not contained within the data source has no effect.
     *
     *  @param photo    The photo to make the currently displayed photo.
     *  @param animated Whether to animate the transition to the new photo.
     */
    public func displayPhoto(_ photo: Photo, animated: Bool) {
        guard let indexOfPhoto = dataSource?.index(of: photo) else { return }

        let photoViewController = newPhotoViewController(
            for: photo,
            atIndex: indexOfPhoto
        )

        setCurrentlyDisplayedViewController(photoViewController, animated: animated)
        updateOverlayInformation()
    }

    /**
     *  Informs the photo viewer that the photo in the data source at this index has
     *  changed.
     *
     *  In response, the photo viewer will retrieve and update the overlay information and
     *  the photo itself.
     *
     *  This method has no effect if the given index is out of bounds in the data source.
     *
     *  @param photoIndex The index of the photo which changed in the data source.
     */
    public func updatePhoto(atIndex photoIndex: Int) {
        guard let photo = dataSource?[photoIndex] else { return }

        notificationCenter
            .post(name: .NYTPhotoViewer.photoImageUpdatedNotification, object: photo)

        if currentlyDisplayedPhoto == photo {
            updateOverlayInformation()
        }
    }

    /**
     *  Tells the photo viewer to reload all data from its data source.
     *
     *  @param animated Whether any resulting transitions should be animated.
     */
    public func reloadPhotos(animated: Bool) {
        guard let dataSource else { return }

        let newCurrentPhoto =
            if let currentlyDisplayedPhoto,
               dataSource.index(of: currentlyDisplayedPhoto) != nil {
                currentlyDisplayedPhoto
            } else {
                dataSource[0]
            }

        if let newCurrentPhoto {
            displayPhoto(newCurrentPhoto, animated: animated)
        }

        if overlayView.isHidden {
            setOverlayView(hidden: false, animated: animated)
        }
    }

    // MARK: - Gesture Recognizers

    @objc
    private func didSingleTap(with tapGestureRecognizer: UITapGestureRecognizer) {
        setOverlayView(hidden: !overlayView.isHidden, animated: true)
    }


    @objc
    private func didPan(with panGestureRecognizer: UIPanGestureRecognizer) {
        if panGestureRecognizer.state == .began {
            transitionController.forcesNonInteractiveDismissal = false
            dismiss(animated: true, userInitiated: true)
        } else {
            transitionController.forcesNonInteractiveDismissal = true
            transitionController .didPan(
                withPanGestureRecognizer: panGestureRecognizer,
                viewToPan: pageViewController.view,
                anchorPoint: boundsCenterPoint
            )
        }
    }

    // MARK: - View Controller Dismissal

    private func dismiss(
        animated: Bool,
        userInitiated isUserInitiated: Bool,
        completion: (() -> Void)? = nil,
    ) {
        if presentedViewController != nil {
            super.dismiss(animated: animated, completion: completion)
            return
        }

        var startingView: UIView?
        if currentlyDisplayedPhoto?.state.image != nil {
            startingView = currentPhotoViewController?.scalingImageView.imageView
        }

        transitionController.startingView = startingView
        transitionController.endingView = referenceViewForCurrentPhoto

        overlayWasHiddenBeforeTransition = overlayView.isHidden
        setOverlayView(hidden: true, animated: animated)

        // Cocoa convention is not to call delegate methods when you do something directly
        // in code, so we'll not call delegate methods if this is a programmatic dismissal:
        if isUserInitiated {
            delegate?.photosViewControllerWillDismiss(self)
        }

        NotificationCenter.default
            .post(name: .NYTPhotoViewer.willDismissNotification, object: self)

        super.dismiss(animated: animated) {
            let isStillOnscreen = self.view.window != nil // Happens when the dismissal is canceled.

            if isStillOnscreen && !self.overlayWasHiddenBeforeTransition {
                self.setOverlayView(hidden: false, animated: true)
            }

            if !isStillOnscreen {
                if isUserInitiated {
                    self.delegate?.photosViewControllerDidDismiss(self)
                }

                NotificationCenter.default
                    .post(name: .NYTPhotoViewer.didDismissNotification, object: self)
            }

            completion?()
        }
    }

    // MARK: - Convenience

    private func setCurrentlyDisplayedViewController(
        _ viewController: any UIViewController & PhotoViewerContainer<Photo>,
        animated: Bool
    ) {
        var animated = animated
        if let photo = viewController.photo,
           let currentlyDisplayedPhoto,
           photo == currentlyDisplayedPhoto
        {
            animated = false
        }

        let currentIdx = currentPhotoViewController?.photoViewItemIndex ?? 0
        let newIdx = viewController.photoViewItemIndex
        let direction: UIPageViewController.NavigationDirection = newIdx < currentIdx
            ? .reverse
            : .forward

        pageViewController.setViewControllers(
            [viewController],
            direction: direction,
            animated: animated
        )
    }

    private func setOverlayView(hidden: Bool, animated: Bool) {
        if hidden == overlayView.isHidden {
            return
        }

        if animated {
            overlayView.isHidden = false

            overlayView.alpha = hidden ? 1 : 0

            UIView
                .animate(
                    withDuration: Self.overlayAnimationDuration,
                    delay: 0,
                    options: [
                        .curveEaseInOut,
                        .allowAnimatedContent,
                        .allowUserInteraction,
                    ],
                ) {
                    self.overlayView.alpha = hidden ? 0 : 1
                } completion: { _ in
                    self.overlayView.isHidden = hidden
                }
        } else {
            overlayView.isHidden = hidden
        }
    }

    private func newPhotoViewController(
        for photo: Photo,
        atIndex index: Int
    ) -> PhotoViewController<Photo> {
        let loadingView = delegate?.photosViewController(self, loadingViewFor: photo)

        let photoViewController = PhotoViewController(
            photo: photo,
            itemIndex: index,
            loadingView: loadingView,
            notificationCenter: notificationCenter,
        )
        photoViewController.delegate = self
        singleTapGestureRecognizer
            .require(toFail: photoViewController.doubleTapGestureRecognizer)

        if let maximumZoomScale = delegate?.photosViewController(
            self,
            maximumZoomScaleFor: photo
        ) {
            photoViewController.scalingImageView.maximumZoomScale = maximumZoomScale
        }

        return photoViewController
    }

    private func newViewController(atIndex index: Int) -> UIViewController? {
        guard let view = delegate?.photosViewController(
            self,
            interstitialViewAtIndex: index
        ) else {
            return nil
        }
        let interstitialViewController = InterstitialViewController(
            view: view,
            itemIndex: index
        )
        return interstitialViewController
    }

    private func didNavigate(to photo: Photo, atIndex index: Int) {
        delegate?.photosViewController(self, didNavigateTo: photo, atIndex: index)
        NotificationCenter
            .default
            .post(name: .NYTPhotoViewer.didNavigateToPhotoNotification, object: self)
    }

    private func didNavigate(toInterstitialView view: UIView, atIndex index: Int) {
        delegate?
            .photosViewController(self, didNavigateToInterstialView: view, atIndex: index)
        NotificationCenter.default.post(
            name: .NYTPhotoViewer.didNavigateToInterstitialViewNotification,
            object: self
        )
    }

    /**
     *  The object conforming to `NYTPhoto` that is currently being displayed by
     *  the ``pageViewController``.
     *
     *  This photo will be one of the photos from the data source.
     */
    public var currentlyDisplayedPhoto: Photo? {
        currentPhotoViewController?.photo
    }

    private var currentPhotoViewController: PhotoViewController<Photo>? {
        pageViewController.viewControllers?.first as? PhotoViewController
    }

    private var referenceViewForCurrentPhoto: UIView? {
        guard let currentlyDisplayedPhoto else { return nil }
        return delegate?
            .photosViewController(self, referenceViewFor: currentlyDisplayedPhoto)
    }

    private var boundsCenterPoint: CGPoint {
        CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

    private var totalItemCount: Int {
        let numberOfInterstitialViews = dataSource?.numberOfInterstitialViews ?? 0
        return dataSource?.numberOfPhotos ?? 0 + numberOfInterstitialViews
    }

    // MARK: - UIPageViewControllerDataSource

    /// internal helper method for the following two delegate methods
    private func nextViewController(
        fromIndex startingIndex: Int,
        delta: Int,
        stopBeforeIndex: Int
    ) -> UIViewController? {
        guard let dataSource else { return nil }
        var itemIndex = startingIndex
        while itemIndex + delta != stopBeforeIndex {
            itemIndex += delta

            if dataSource.isPhoto(atIndex: itemIndex) {
                return dataSource[itemIndex].map {
                    newPhotoViewController(for: $0, atIndex: itemIndex)
                }
            }
            if let possibleVC = newViewController(atIndex: itemIndex) {
                return possibleVC
            }
        }
        return nil
    }

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? PhotoViewController<Photo> else {
            return nil
        }
        return nextViewController(
            fromIndex: viewController.photoViewItemIndex,
            delta: -1,
            stopBeforeIndex: -1
        )
    }

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? PhotoViewController<Photo> else {
            return nil
        }
        return nextViewController(
            fromIndex: viewController.photoViewItemIndex,
            delta: 1,
            stopBeforeIndex: totalItemCount
        )
    }

    // MARK: - UIPageViewControllerDelegate

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed else { return }
        updateOverlayInformation()
        guard let viewController = currentPhotoViewController else {
            return
        }
        if let photo = viewController.photo {
            didNavigate(to: photo, atIndex: viewController.photoViewItemIndex)
        } else if let interstitialView = viewController.interstitialView {
            didNavigate(
                toInterstitialView: interstitialView,
                atIndex: viewController.photoViewItemIndex
            )
        }
    }

    // MARK: UIActivityItemSource protocol procedures to support sharesheet

    /// called to fetch data after an activity is selected. you can return nil.
    public func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        nil
    }

    /// called to determine data type. only the class of the return type is consulted.
    /// it should match what -itemForActivityType: returns later
    public func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        NSObject()
    }

    /// called to fetch LinkPresentation metadata for the activity item.
    public func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = currentlyDisplayedPhoto?.attributedCaptionSummary?.string
        return metaData
    }
}

extension PhotosViewController: PhotoViewControllerDelegate {
    public func photoViewController(
        _ photoViewController: PhotoViewController<Photo>,
        didLongPressWithGestureRecognizer longPressGestureRecognizer: UILongPressGestureRecognizer
    ) {
        guard let photo = photoViewController.photo else { return }
        shouldHandleLongPress = false

        let clientDidHandle = delegate?.photosViewController(
            self,
            handleLongPressFor: photo,
            withGestureRecognizer: longPressGestureRecognizer
        ) ?? false

        shouldHandleLongPress = !clientDidHandle

        if shouldHandleLongPress, let grView = longPressGestureRecognizer.view {
            let menuController = UIMenuController.shared
            let targetRect = CGRect(
                origin: longPressGestureRecognizer.location(in: grView),
                size: .zero
            )
            menuController.showMenu(from: grView, rect: targetRect)
        }
    }
}
