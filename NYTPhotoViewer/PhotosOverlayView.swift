//
//  NYTPhotosOverlayView.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/17/15.
//
//

import UIKit

/**
 *  A view that overlays an ``PhotosViewController``, and houses the left and right bar
 *  button items, a title, and a caption view.
 */
open class PhotosOverlayView: UIView {

    /**
     *  The internal navigation bar used to set the bar button items and title of
     *  the overlay.
     */
    public let navigationBar = UINavigationBar()

    /**
     *  A view representing the caption for the photo, which will be set to full width and
     *  locked to the bottom. Can be any `UIView` object, but is expected to respond to
     *  `intrinsicContentSize` appropriately to calculate height.
     */
    public var captionView: UIView? {
        willSet {
            willSetCaptionView(newValue)
        }
    }

    /**
     *  Whether the `captionView` should respect the safe area or not
     */
    public var captionViewRespectsSafeArea: Bool = false

    private var navigationItem = UINavigationItem(title: "")

    // MARK: - UIView
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBar()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNavigationBar()
    }

    // Pass the touches down to other views: http://stackoverflow.com/a/8104378
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView === self {
            return nil
        }

        return hitView
    }

    open override func layoutSubviews() {
        // The navigation bar has a different intrinsic content size upon rotation,
        // so we must update to that new size.
        // Do it without animation to more closely match the behavior in `UINavigationController`
        UIView.performWithoutAnimation {
            navigationBar.invalidateIntrinsicContentSize()
            navigationBar.layoutIfNeeded()
        }

        super.layoutSubviews()

        if let captionView = self.captionView as? PhotoCaptionViewLayoutWidthHinting {
            captionView.preferredMaxLayoutWidth = bounds.size.width
        }
    }

    // MARK: - PhotosOverlayView

    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        // Make navigation bar background fully transparent.
        navigationBar.backgroundColor = .clear
        navigationBar.barTintColor = nil
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationBar.items = [navigationItem]

        addSubview(navigationBar)

        let topConstraint = navigationBar.topAnchor
            .constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        let leadingConstraint = navigationBar.leadingAnchor
            .constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
        let trailingConstraint = navigationBar.trailingAnchor
            .constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        addConstraints([topConstraint, leadingConstraint, trailingConstraint])
    }

    private func willSetCaptionView(_ captionView: UIView?) {
        if self.captionView === captionView {
            return
        }

        self.captionView?.removeFromSuperview()

        guard let captionView else { return }
        captionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionView)

        if captionViewRespectsSafeArea {
            let bottomConstraint = captionView.bottomAnchor
                .constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            let leadingConstraint = captionView.leadingAnchor
                .constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            let trailingAnchor = captionView.trailingAnchor
                .constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
            addConstraints([bottomConstraint, leadingConstraint, trailingAnchor])
        } else {
            let bottomConstraint = NSLayoutConstraint(
                item: captionView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: 0,
            )
            let widthConstraint = NSLayoutConstraint(
                item: captionView,
                attribute: .width,
                relatedBy: .equal,
                toItem: self,
                attribute: .width,
                multiplier: 1,
                constant: 0,
            )
            let horizontalPositionConstraint = NSLayoutConstraint(
                item: captionView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0,
            )
            addConstraints(
                [bottomConstraint, widthConstraint, horizontalPositionConstraint]
            )
        }
    }

    /**
     *  The bar button item appearing at the top left of the overlay.
     */
    public var leftBarButtonItem: UIBarButtonItem? {
        get {
            navigationItem.leftBarButtonItem
        }
        set {
            navigationItem.setLeftBarButton(newValue, animated: false)
        }
    }

    /**
     *  The bar button items appearing at the top left of the overlay.
     */
    public var leftBarButtonItems: [UIBarButtonItem]? {
        get {
            navigationItem.leftBarButtonItems
        }
        set {
            navigationItem.setLeftBarButtonItems(newValue, animated: false)
        }
    }

    /**
     *  The bar button item appearing at the top right of the overlay.
     */
    public var rightBarButtonItem: UIBarButtonItem? {
        get {
            navigationItem.rightBarButtonItem
        }
        set {
            navigationItem.setRightBarButton(newValue, animated: false)
        }
    }

    /**
     *  The bar button items appearing at the top right of the overlay.
     */
    public var rightBarButtonItems: [UIBarButtonItem]? {
        get {
            navigationItem.rightBarButtonItems
        }
        set {
            navigationItem.setRightBarButtonItems(newValue, animated: false)
        }
    }

    /**
     *  The title of the overlay. Centered between the left and right bar button items.
     */
    public var title: String? {
        get {
            navigationItem.title
        }
        set {
            navigationItem.title = newValue
        }
    }

    /**
     *  The attributes of the overlay's title.
     */
    public var titleTextAttributes: [NSAttributedString.Key : Any]? {
        get {
            navigationBar.titleTextAttributes
        }
        set {
            navigationBar.titleTextAttributes = newValue
        }
    }
}
