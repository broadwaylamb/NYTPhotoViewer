//
//  PhotoViewController.swift
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/11/15.
//
//

import UIKit

@MainActor
public protocol PhotoViewControllerDelegate<Photo>: AnyObject {
    associatedtype Photo: PhotoProtocol

    /**
     *  Called when a long press is recognized.
     *
     *  @param photoViewController        The ``PhotoViewController`` instance that sent
     *                                    the delegate message.
     *  @param longPressGestureRecognizer The long press gesture recognizer that
     *                                    recognized the long press.
     */
    func photoViewController(
        _ photoViewController: PhotoViewController<Photo>,
        didLongPressWithGestureRecognizer longPressGestureRecognizer: UILongPressGestureRecognizer
    )
}

extension PhotoViewControllerDelegate {
    func photoViewController(
        _ photoViewController: PhotoViewController<Photo>,
        didLongPressWithGestureRecognizer longPressGestureRecognizer: UILongPressGestureRecognizer
    ) {}
}

/**
 *  The view controller controlling the display of a single photo object.
 */
public final class PhotoViewController<Photo: PhotoProtocol>: UIViewController, UIScrollViewDelegate {
    public let photo: Photo
    public let photoViewItemIndex: Int

    /**
     *  The internal scaling image view used to display the photo.
     */
    public let scalingImageView: ScalingImageView

    /**
     *  The internal activity view shown while the image is loading.
     */
    public var loadingView: UIView?

    private let notificationCenter: NotificationCenter?

    /**
     *  The gesture recognizer used to detect the double tap gesture used for zooming on
     *  photos.
     */
    public private(set) lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(
            target: self,
            action: #selector(didDoubleTap)
        )
        gr.numberOfTapsRequired = 2
        return gr
    }()

    private lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(
        target: self,
        action: #selector(didLongPress)
    )

    /**
     *  The object that acts as the photo view controller's delegate.
     */
    public weak var delegate: (any PhotoViewControllerDelegate<Photo>)?

    deinit {
        notificationCenter?.removeObserver(self)
    }

    // MARK: - UIViewController

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        notificationCenter?.addObserver(
            self,
            selector: #selector(photoImageUpdated(with:)),
            name: .NYTPhotoViewer.photoImageUpdatedNotification,
            object: nil
        )

        scalingImageView.frame = view.bounds
        view.addSubview(scalingImageView)

        if let loadingView {
            view.addSubview(loadingView)
            loadingView.sizeToFit()
        }

        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scalingImageView.frame = view.bounds

        if let loadingView {
            loadingView.sizeToFit()
            loadingView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        }
    }

    public override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    // MARK: - PhotoViewController

    /**
     *  The designated initializer that takes the photo and activity view.
     *
     *  @param photo              The photo object that this view controller manages.
     *  @param itemIndex          The index of this view controller in the photo viewer
     *                            collection.
     *  @param loadingView        The view to display while the photo's image loads.
     *                            This view will be hidden when the image loads.
     *  @param notificationCenter The notification center on which to observe
     *                            the ``photoImageUpdatedNotification``.
     */
    public init(
        photo: Photo,
        itemIndex: Int,
        loadingView: UIView?,
        notificationCenter: NotificationCenter?,
    ) {
        self.photo = photo
        self.photoViewItemIndex = itemIndex

        let photoImage = photo.state.image
        scalingImageView = ScalingImageView(image: photoImage, frame: .zero)
        self.loadingView = photoImage == nil ? Self.setupLoadingView(loadingView) : nil
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
        scalingImageView.delegate = self
    }

    private static func setupLoadingView(_ customLoadingView: UIView?) -> UIView {
        if let customLoadingView {
            return customLoadingView
        }
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        return activityIndicator
    }

    @objc
    private func photoImageUpdated(with notification: Notification) {
        if let photo = notification.object as? Photo, photo == self.photo {
            updateImage(photo.state.image)
        }
    }

    private func updateImage(_ image: UIImage?) {
        scalingImageView.updateImage(image)
        if image != nil {
            loadingView?.removeFromSuperview()
        } else if let loadingView {
            view.addSubview(loadingView)
        }
    }

    // MARK: - Gesture Recognizers

    @objc
    private func didDoubleTap(with recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: scalingImageView.imageView)

        var newZoomScale = scalingImageView.maximumZoomScale

        if scalingImageView.zoomScale >= scalingImageView.maximumZoomScale
            || abs(scalingImageView.zoomScale - scalingImageView.maximumZoomScale) <= 0.01
        {
            newZoomScale = scalingImageView.minimumZoomScale
        }

        let scrollViewSize = scalingImageView.bounds.size

        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - width / 2
        let originY = pointInView.y - height / 2

        let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)

        scalingImageView.zoom(to: rectToZoomTo, animated: true)
    }

    @objc
    private func didLongPress(with recognizer: UILongPressGestureRecognizer) {
        if let delegate, recognizer.state == .began {
            delegate
                .photoViewController(self, didLongPressWithGestureRecognizer: recognizer)
        }
    }

    // MARK: - UIScrollViewDelegate

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        scalingImageView.imageView
    }

    public func scrollViewWillBeginZooming(
        _ scrollView: UIScrollView,
        with view: UIView?
    ) {
        scrollView.panGestureRecognizer.isEnabled = true
    }

    public func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat
    ) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to
        // render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view
        // when it is not needed.
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.panGestureRecognizer.isEnabled = false
        }
    }
}
