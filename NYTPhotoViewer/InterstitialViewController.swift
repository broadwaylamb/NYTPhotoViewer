//
//  NYTInterstitialViewController.m
//  NYTPhotoViewer
//
//  Created by Howarth, Craig on 4/17/18.
//  Copyright © 2018 NYTimes. All rights reserved.
//

import UIKit

/**
 *  The view controller controlling the display of a interstitial view.
 */
internal final class InterstitialViewController: UIViewController {
    private var photo: (any NYTPhoto)?
    private let interstitialView: UIView?
    private var photoViewItemIndex: Int = 0
    private var constraints: [NSLayoutConstraint] = []

    /**
     *  The designated initializer that takes an interstitial view.
     *
     *  @param view      The view object that this view controller manages.
     *  @param itemIndex The index of this view controller in the photo viewer collection.
     */
    public init(view: UIView?, itemIndex: Int) {
        interstitialView = view
        photoViewItemIndex = itemIndex
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

    public override convenience init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        self.init(view: nil, itemIndex: 0)
    }

    public required init?(coder: NSCoder) {
        interstitialView = nil
        super.init(coder: coder)
    }

    private func prepareLayout() {
        guard let interstitialView else { return }
        if interstitialView.translatesAutoresizingMaskIntoConstraints {
            interstitialView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        } else {
            constraints = [
                interstitialView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                interstitialView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if let interstitialView {
            view.addSubview(interstitialView)
        }
        prepareLayout()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        prepareLayout()
    }

    public override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}
