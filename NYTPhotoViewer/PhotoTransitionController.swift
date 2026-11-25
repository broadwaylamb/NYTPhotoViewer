//
//  PhotoTransitionController.swift
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/13/15.
//
//

import UIKit

/**
 *  An object that manages both animated transitions and interactive transitions,
 *  acting as the transitioning delegate and internally coordinating multiple objects
 *  that do the animating and interactivity work.
 */
public final class PhotoTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    private let animator = PhotoTransitionAnimator()
    private let interactionController = PhotoDismissalInteractionController()

    /**
     *  Forces the dismiss to animate, instead of the default behavior of being
     *  interactive.
     */
    public var forcesNonInteractiveDismissal = true

    // MARK: - PhotoTransitionController

    /**
     *  Call when new events are received from a `UIPanGestureRecognizer`.
     *  Internally passes off to interaction controller, which pans the appropriate view,
     *  and makes decisions when to finish or cancel the interactive transition back to
     *  the anchor point. Intended to be called after a dismissal has started with
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
        interactionController
            .didPan(
                withPanGestureRecognizer: panGestureRecognizer,
                viewToPan: viewToPan,
                anchorPoint: anchorPoint
            )
    }

    /**
     *  The view from which to start an image zooming transition. This view may be hidden
     *  or shown in the transition, but will never be removed or changed in its view
     *  hierarchy.
     */
    public var startingView: UIView? {
        get {
            animator.startingView
        }
        set {
            animator.startingView = newValue
        }
    }

    /**
     *  The view from which to end an image zooming transition. This view may be hidden or
     *  shown in the transition, but will never be removed or changed in its view
     *  hierarchy.
     */
    public var endingView: UIView? {
        get {
            animator.endingView
        }
        set {
            animator.endingView = newValue
        }
    }

    // MARK: - UIViewControllerTransitioningDelegate

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController,
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        animator.isDismissing = false
        return animator
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        animator.isDismissing = true
        return animator
    }

    public func interactionControllerForDismissal(
        using animator: any UIViewControllerAnimatedTransitioning
    ) -> (any UIViewControllerInteractiveTransitioning)? {
        if forcesNonInteractiveDismissal {
            return nil
        }

        // The interaction controller will be hiding the ending view, so we should get and
        // set a visible version now.
        self.animator.endingViewForAnimation = PhotoTransitionAnimator
            .newAnimationView(fromView: endingView)

        interactionController.animator = animator
        interactionController.shouldAnimateUsingAnimator = endingView != nil
        interactionController.viewToHideWhenBeginningTransition =
            startingView != nil ? endingView : nil

        return interactionController
    }
}
