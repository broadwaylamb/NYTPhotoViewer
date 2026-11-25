//
//  NYTScalingImageView.m
//  NYTPhotoViewer
//
//  Created by Harrison, Andrew on 7/23/13.
//  Copyright (c) 2015 The New York Times Company. All rights reserved.
//

import UIKit

public final class ScalingImageView: UIScrollView {

    /**s
     *  The image view used internally as the contents of the scroll view.
     */
    public let imageView: UIImageView

    // MARK: - UIView

    public convenience override init(frame: CGRect) {
        self.init(image: UIImage(), frame: frame)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        centerScrollViewContents()
    }

    public override var frame: CGRect {
        get {
            super.frame
        }
        set {
            super.frame = newValue
            updateZoomScale()
            centerScrollViewContents()
        }
    }

    // MARK: - ScalingImageView

    /**
     *  Initializes a scaling image view with a ``/UIKit/UIImage``. This object is
     *  a ``/UIKit/UIScrollView`` that contains a ``/UIKit/UIImageView``. This allows for zooming and
     *  panning around the image.
     *
     *  @param image A ``/UIKit/UIImage`` for zooming and panning.
     *  @param frame The frame of the view.
     */
    public init(image: UIImage?, frame: CGRect) {
        imageView = UIImageView(image: image)
        super.init(frame: frame)
        updateImage(image)
        addSubview(imageView)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = .fast
        updateZoomScale()
    }

    // MARK: - Setup

    /**
     *  Updates the image in the image view and centers and zooms the new image.
     *
     *  @param image The new image to display in the image view.
     */
    public func updateImage(_ image: UIImage?) {
        // Remove any transform currently applied by the scroll view zooming.
        imageView.transform = .identity
        imageView.image = image
        let imageSize = image?.size ?? .zero
        imageView.frame = CGRect(
            origin: .zero,
            size: imageSize,
        )
        contentSize = imageSize
        updateZoomScale()
        centerScrollViewContents()
    }

    private func updateZoomScale() {
        guard let imageSize = imageView.image?.size else { return }
        let scrollViewFrame = bounds

        let scaleWidth = scrollViewFrame.size.width / imageSize.width
        let scaleHeight = scrollViewFrame.size.height / imageSize.height
        let minScale = min(scaleWidth, scaleHeight)

        minimumZoomScale = minScale
        maximumZoomScale = max(minScale, maximumZoomScale)
        zoomScale = minimumZoomScale

        // scrollView.panGestureRecognizer.isEnabled is on by default and enabled by
        // viewWillLayoutSubviews in the container controller so disable it here
        // to prevent an interference with the container controller's pan gesture.
        //
        // This is enabled in scrollViewWillBeginZooming so panning while zoomed-in
        // is unaffected.
        panGestureRecognizer.isEnabled = false
    }

    // MARK: - Centering

    /**
     *  Centers the image inside of the scroll view.
     *  Typically used after rotation, or when zooming has finished.
     */
    public func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        if contentSize.width < bounds.width {
            horizontalInset = (bounds.width - contentSize.width) * 0.5
        }

        if contentSize.height < bounds.height {
            verticalInset = (bounds.height - contentSize.height) * 0.5
        }

        // Use `contentInset` to center the contents in the scroll view.
        // Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset,
        )
    }
}
