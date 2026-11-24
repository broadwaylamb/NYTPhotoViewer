//
//  PhotoTransitionAnimator.swift
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/17/15.
//
//

import UIKit

/**
 *  An object that controls the animated transition of photo presentation and dismissal.
 */
@objc(NYTPhotoTransitionAnimator)
public final class PhotoTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private static let durationWithZooming: CGFloat = 0.5
    private static let durationWithoutZooming: CGFloat = 0.3
    private static let backgroundFadeDurationRatio: CGFloat = 4.0 / 9.0
    private static let endingViewFadeInDurationRatio: CGFloat = 0.1
    private static let startingViewFadeOutDurationRatio: CGFloat = 0.05
    private static let springDamping: CGFloat = 0.9

    private weak var toViewController: UIViewController?
    private weak var fromViewController: UIViewController?

    /**
     *  The view from which to start an image zooming transition.
     *  This view may be hidden or shown in the transition, but will never be removed or
     *  changed in its view hierarchy.
     */
    @objc
    public var startingView: UIView?

    /**
     *  The view from which to end an image zooming transition.
     *  This view may be hidden or shown in the transition, but will never be removed or
     *  changed in its view hierarchy.
     */
    @objc
    public var endingView: UIView?

    /**
     *  The view that is used for animating the starting view.
     *  If no view is set, the starting view is screenshotted and the relevant properties
     *  are copied to the new view.
     */
    @objc
    public var startingViewForAnimation: UIView?

    /**
     *  The view that is used for animating the ending view.
     *  If no view is set, the ending view is screenshotted and relevant properties copied
     *  to the new view.
     */
    @objc
    public var endingViewForAnimation: UIView?

    /**
     *  Whether this transition is a dismissal. If `false`, presentation is assumed.
     */
    @objc
    public var isDismissing = false

    /**
     *  The duration of the animation when zooming is performed.
     */
    public var animationDurationWithZooming = durationWithZooming

    /**
     *  The duration of the animation when only fading and not zooming is performed.
     */
    public var animationDurationWithoutZooming = durationWithoutZooming

    /**
     *  The ratio (from 0.0 to 1.0) of the total animation duration that the background
     *  fade duration takes.
     */
    public var animationDurationFadeRatio = backgroundFadeDurationRatio {
        didSet {
            animationDurationFadeRatio = min(animationDurationFadeRatio, 1)
        }
    }

    /**
     *  The ratio (from 0.0 to 1.0) of the total animation duration that the ending view
     *  fade in duration takes.
     */
    public var animationDurationEndingViewFadeInRatio = endingViewFadeInDurationRatio {
        didSet {
            animationDurationEndingViewFadeInRatio =
                min(animationDurationEndingViewFadeInRatio, 1)
        }
    }

    /**
     *  The ratio (from 0.0 to 1.0) of the total animation duration that the starting view
     *  fade out duration takes after the ending view fade in completes.
     */
    public var animationDurationStartingViewFadeOutRatio = startingViewFadeOutDurationRatio {
        didSet {
            animationDurationStartingViewFadeOutRatio = max(animationDurationStartingViewFadeOutRatio, 1)
        }
    }

    /**
     *  The value passed as the spring damping argument to
     *  `animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:`
     *  for the zooming animation.
     */
    public var zoomingAnimationSpringDamping = springDamping

    // MARK: - PhotoTransitionAnimator

    private func setupTransitionContainerHierarchy(
        with transitionContext: any UIViewControllerContextTransitioning
    ) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to),
              let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            return
        }

        self.toViewController = toViewController
        self.fromViewController = fromViewController

        toView.frame = transitionContext.finalFrame(for: toViewController)

        if toViewController.parent != nil {
            toViewController.beginAppearanceTransition(true, animated: true)
        }

        if fromViewController.parent != nil {
            fromViewController.beginAppearanceTransition(false, animated: true)
        }

        if !toView.isDescendant(of: transitionContext.containerView) {
            transitionContext.containerView.addSubview(toView)
        }

        if isDismissing {
            transitionContext.containerView.bringSubviewToFront(fromView)
        }
    }

    // MARK: - Fading

    private func performFadeAnimation(
        with transitionContext: any UIViewControllerContextTransitioning
    ) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to)
        else {
            return
        }

        let viewToFade = isDismissing ? fromView : toView
        let beginningAlpha: CGFloat = isDismissing ? 1 : 0
        let endingAlpha: CGFloat = isDismissing ? 0 : 1

        viewToFade.alpha = beginningAlpha

        UIView.animate(withDuration: fadeDuration(for: transitionContext)) {
            viewToFade.alpha = endingAlpha
        } completion: { _ in
            if !self.shouldPerformZoomingAnimation {
                self.completeTransition(with: transitionContext)
            }
        }
    }

    private func fadeDuration(
        for transitionContext: any UIViewControllerContextTransitioning
    ) -> CGFloat {
        shouldPerformZoomingAnimation
            ? transitionDuration(using: transitionContext) * animationDurationFadeRatio
            : transitionDuration(using: transitionContext)
    }

    // MARK: - Zooming

    private func performZoomingAnimation(
        with transitionContext: any UIViewControllerContextTransitioning
    ) {
        guard let startingView, let endingView else { return }
        let containerView = transitionContext.containerView

        // Create a brand new view with the same contents for the purposes of animating
        // this new view and leaving the old one alone.
        guard let startingViewForAnimation = self.startingViewForAnimation
                ?? Self.newAnimationView(fromView: startingView) else { return }

        guard let endingViewForAnimation = self.endingViewForAnimation
                ?? Self.newAnimationView(fromView: endingView) else { return }

        let finalEndingViewTransform = endingView.transform

        let endingViewInitialTransform =
            startingViewForAnimation.frame.height / endingViewForAnimation.frame.height
        let translatedStartingViewCenter =
            Self.centerPoint(for: startingView, translatedTo: containerView)

        startingViewForAnimation.center = translatedStartingViewCenter

        endingViewForAnimation.transform = CGAffineTransformScale(
            endingViewForAnimation.transform,
            endingViewInitialTransform,
            endingViewInitialTransform,
        )
        endingViewForAnimation.center = translatedStartingViewCenter
        endingViewForAnimation.alpha = 0

        containerView.addSubview(startingViewForAnimation)
        containerView.addSubview(endingViewForAnimation)

        // Hide the original ending view and starting view until the completion of
        // the animation.
        endingView.alpha = 0
        startingView.alpha = 0

        let fadeInDuration = transitionDuration(using: transitionContext)
            * animationDurationEndingViewFadeInRatio
        let fadeOutDuration = transitionDuration(using: transitionContext)
            * animationDurationStartingViewFadeOutRatio

        // Ending view / starting view replacement animation
        UIView.animate(
            withDuration: fadeInDuration,
            delay: 0,
            options: [.allowAnimatedContent, .beginFromCurrentState],
        ) {
            endingViewForAnimation.alpha = 1
        } completion: { _ in
            UIView.animate(
                withDuration: fadeOutDuration,
                delay: 0,
                options: [.allowAnimatedContent, .beginFromCurrentState],
            ) {
                startingViewForAnimation.alpha = 0
            } completion: { _ in
                startingViewForAnimation.removeFromSuperview()
            }
        }

        let startingViewFinalTransform = 1 / endingViewInitialTransform
        let translatedEndingViewFinalCenter =
            Self.centerPoint(for: endingView, translatedTo: containerView)

        // Zoom animation
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: zoomingAnimationSpringDamping,
            initialSpringVelocity: 0,
            options: [.allowAnimatedContent, .beginFromCurrentState],
        ) {
            endingViewForAnimation.transform = finalEndingViewTransform
            endingViewForAnimation.center = translatedEndingViewFinalCenter
            startingViewForAnimation.transform = CGAffineTransformScale(
                startingViewForAnimation.transform,
                startingViewFinalTransform,
                startingViewFinalTransform,
            )
            startingViewForAnimation.center = translatedEndingViewFinalCenter
        } completion: { _ in
            endingView.alpha = 1
            startingView.alpha = 1
            self.completeTransition(with: transitionContext)
        }
    }

    // MARK: - Convenience
    private var shouldPerformZoomingAnimation: Bool {
        startingView != nil && endingView != nil
    }

    private func completeTransition(
        with transitionContext: any UIViewControllerContextTransitioning
    ) {
        if transitionContext.isInteractive {
            if transitionContext.transitionWasCancelled {
                transitionContext.cancelInteractiveTransition()
            } else {
                transitionContext.finishInteractiveTransition()
            }
        }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    private static func centerPoint(
        for view: UIView,
        translatedTo containerView: UIView
    ) -> CGPoint {
        var centerPoint = view.center

        // Special case for zoomed scroll views.
        if let scrollView = view.superview as? UIScrollView, scrollView.zoomScale != 1 {
            centerPoint.x += (scrollView.bounds.width - scrollView.contentSize.width) / 2
            centerPoint.x += scrollView.contentOffset.x

            centerPoint.y += (scrollView.bounds.height - scrollView.contentSize.height) / 2
            centerPoint.y += scrollView.contentOffset.y
        }

        return view.superview?.convert(centerPoint, to: containerView) ?? centerPoint
    }

    /**
     *  Convenience method for creating a view for animation from another arbitrary view.
     *  Attempts to create an identical view in the most efficient way possible.
     *  Returns `nil` if the passed-in view is `nil`.
     *
     *  @param view The view from which to create the animation.
     *
     *  @return A new view identical in appearance to the passed-in view, with relevant
     *  properties transferred. Not a member of any view hierarchy.
     *  Return `nil` if the passed-in view is `nil`.
     */
    @objc
    public static func newAnimationView(fromView view: UIView?) -> UIView? {
        guard let view else { return nil }

        if let contents = view.layer.contents {
            let animationView: UIView
            if let imageView = view as? UIImageView {
                // The case of UIImageView is handled separately since the mere layer's
                // contents (i.e. CGImage in this case) doesn't
                // seem to contain proper informations about the image orientation for
                // portrait images taken directly on the device.
                // See https://github.com/NYTimes/NYTPhotoViewer/issues/115
                animationView = UIImageView(image: imageView.image)
                animationView.bounds = view.bounds
            } else {
                animationView = UIView(frame: view.frame)
                animationView.layer.contents = contents
                animationView.layer.bounds = view.layer.bounds
            }

            animationView.layer.cornerRadius = view.layer.cornerRadius
            animationView.layer.masksToBounds = view.layer.masksToBounds
            animationView.contentMode = view.contentMode
            animationView.transform = view.transform

            return animationView
        } else {
            return view.snapshotView(afterScreenUpdates: true)
        }
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    public func animationEnded(_ transitionCompleted: Bool) {
        if let toViewController, toViewController.parent != nil {
            toViewController.endAppearanceTransition()
        }
        if let fromViewController, fromViewController.parent != nil {
            fromViewController.endAppearanceTransition()
        }
    }

    public func transitionDuration(
        using transitionContext: (any UIViewControllerContextTransitioning)?
    ) -> TimeInterval {
        shouldPerformZoomingAnimation
            ? animationDurationWithZooming
            : animationDurationWithoutZooming
    }

    public func animateTransition(
        using transitionContext: any UIViewControllerContextTransitioning
    ) {
        setupTransitionContainerHierarchy(with: transitionContext)
        performFadeAnimation(with: transitionContext)
        if shouldPerformZoomingAnimation {
            performZoomingAnimation(with: transitionContext)
        }
    }
}
