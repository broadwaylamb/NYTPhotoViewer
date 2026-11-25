//
//  NYTPhotoDismissalInteractionController.swift
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/17/15.
//
//

import UIKit

/**
 *  An object that controls an interactive photo dismissal transition.
 */
public final class PhotoDismissalInteractionController: NSObject, UIViewControllerInteractiveTransitioning {
    private static let panDismissDistanceRatio: CGFloat = 50.0 / 667.0 // distance over iPhone 6 height.
    private static let panDismissMaximumDuration: CGFloat = 0.45
    private static let returnToCenterVelocityAnimationRatio: CGFloat = 0.00007 // Arbitrary value that looked decent.

    /**
     *  The animator object associated with the interactive transition.
     */
    public var animator: UIViewControllerAnimatedTransitioning?

    /**
     *  If set, this view will be hidden as soon as the interactive transition starts,
     *  and shown after it ends.
     */
    public var viewToHideWhenBeginningTransition: UIView?

    /**
     *  A boolean determining whether, after reaching a certain panning threshold that
     *  constitutes a dismissal, the animator object should be used to finish
     *  the transition.
     */
    public var shouldAnimateUsingAnimator: Bool = false

    private var transitionContext: (any UIViewControllerContextTransitioning)?

    // MARK: - PhotoDismissalInteractionController

    /**
     *  Call when new events are received from a `UIPanGestureRecognizer`.
     *  Pans the appropriate view, and makes decisions when to finish or cancel
     *  the interactive transition back to the anchor point
     *  Intended to be called after a dismissal has started with
     *  `dismissViewControllerAnimated:completion:`.
     *
     *  @param panGestureRecognizer The `UIPanGestureRecognizer` that caused the pan event.
     *  @param viewToPan            The view to pan using the location from the pan
     *                              gesture recognizer.
     *  @param anchorPoint          The point at which the pan began and should end if
     *                              cancelled. Should be in the coordinates of the "from"
     *                              view controller's view on dismissal.
     */
    public func didPan(
        withPanGestureRecognizer panGestureRecognizer: UIPanGestureRecognizer,
        viewToPan: UIView,
        anchorPoint: CGPoint,
    ) {
        guard let transitionContext,
              let fromView = transitionContext.view(forKey: .from) else {
            return
        }
        let translatedPanGesturePoint = panGestureRecognizer.translation(in: fromView)
        let newCenterPoint = CGPoint(
            x: anchorPoint.x,
            y: anchorPoint.y + translatedPanGesturePoint.y,
        )

        // If we are presenting fullscreen, the presenting view controller's view will
        // have been removed from the view hierarchy when the presentation animation
        // finished. We need to put it back in the view hierarchy in order for
        // it to appear behind the interactive dismissal animation.

        if let toView = transitionContext.view(forKey: .to),
           toView.superview == nil,
           let toViewController = transitionContext.viewController(forKey: .to)
        {
            toView.frame = transitionContext.finalFrame(for: toViewController)
            if !toView.isDescendant(of: transitionContext.containerView) {
                transitionContext.containerView.addSubview(toView)
            }
            transitionContext.containerView.bringSubviewToFront(fromView)
        }

        // Pan the view on pace with the pan gesture.
        viewToPan.center = newCenterPoint

        let verticalDelta = newCenterPoint.y - anchorPoint.y

        let backgroundAlpha = backgroundAlphaForPanning(
            fromView: fromView,
            withVerticalDelta: verticalDelta,
        )
        fromView.backgroundColor = fromView.backgroundColor?
            .withAlphaComponent(backgroundAlpha)

        if panGestureRecognizer.state == .ended {
            finishPan(
                withPanGestureRecognizer: panGestureRecognizer,
                verticalDelta: verticalDelta,
                viewToPan: viewToPan,
                anchorPoint: anchorPoint
            )
        }
    }

    private func finishPan(
        withPanGestureRecognizer panGestureRecognizer: UIPanGestureRecognizer,
        verticalDelta: CGFloat,
        viewToPan: UIView,
        anchorPoint: CGPoint,
    ) {
        guard let transitionContext,
              let fromView = transitionContext.view(forKey: .from) else {
            return
        }

        // Return to center case.
        let velocityY = panGestureRecognizer.velocity(in: panGestureRecognizer.view).y

        var animationDuration =
            abs(velocityY) * Self.returnToCenterVelocityAnimationRatio + 0.2
        var finalPageViewCenterPoint = anchorPoint
        var finalBackgroundAlpha = 1.0

        let dismissDistance = Self.panDismissDistanceRatio * fromView.bounds.height
        let isDismissing = abs(verticalDelta) > dismissDistance

        var didAnimateUsingAnimator = false

        if isDismissing {
            if shouldAnimateUsingAnimator {
                animator?.animateTransition(using: transitionContext)
                didAnimateUsingAnimator = true
            }
            else {
                let isPositiveDelta = verticalDelta >= 0

                let modifier: CGFloat = isPositiveDelta ? 1 : -1
                let finalCenterY = fromView.bounds.midY + modifier * fromView.bounds.height
                finalPageViewCenterPoint = CGPoint(x: fromView.center.x, y: finalCenterY)

                // Maintain the velocity of the pan, while easing out.
                animationDuration = abs(finalPageViewCenterPoint.y - viewToPan.center.y) / abs(velocityY)
                animationDuration = min(animationDuration, Self.panDismissMaximumDuration)

                finalBackgroundAlpha = 0.0;
            }
        } else {
            // Interactive transition was canceled (i.e. the user changed their mind and
            // decided not to finish the dismissal), so if we are presenting fullscreen,
            // remove the presenting view controller's view.
            if (transitionContext.presentationStyle == .fullScreen) {
                let toView = transitionContext.view(forKey: .to)
                toView?.removeFromSuperview()
            }
        }

        if !didAnimateUsingAnimator {
            UIView
                .animate(
                    withDuration: animationDuration,
                    delay: 0,
                    options: .curveEaseOut,
                ) {
                    viewToPan.center = finalPageViewCenterPoint
                    fromView.backgroundColor = fromView.backgroundColor?
                        .withAlphaComponent(finalBackgroundAlpha)
                } completion: { _ in
                    if isDismissing {
                        transitionContext.finishInteractiveTransition()
                    } else {
                        transitionContext.cancelInteractiveTransition()
                    }

                    self.viewToHideWhenBeginningTransition?.alpha = 1

                    transitionContext.completeTransition(
                        isDismissing && !transitionContext.transitionWasCancelled
                    )

                    self.transitionContext = nil
                }
        } else {
            self.transitionContext = nil
        }
    }

    private func backgroundAlphaForPanning(
        fromView: UIView,
        withVerticalDelta verticalDelta: CGFloat,
    ) -> CGFloat {
        let startingAlpha: CGFloat = 1.0
        let finalAlpha: CGFloat = 0.1;
        let totalAvailableAlpha = startingAlpha - finalAlpha

        let maximumDelta = fromView.bounds.height / 2 // Arbitrary value.

        let deltaAsPercentageOfMaximum = min(abs(verticalDelta) / maximumDelta, 1)

        return startingAlpha - deltaAsPercentageOfMaximum * totalAvailableAlpha
    }

    // MARK: - UIViewControllerInteractiveTransitioning

    public func startInteractiveTransition(
        _ transitionContext: any UIViewControllerContextTransitioning
    ) {
        viewToHideWhenBeginningTransition?.alpha = 0
        self.transitionContext = transitionContext
    }
}
