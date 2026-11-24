//
//  NYTPhotoCaptionView.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/18/15.
//
//

import UIKit

/**
 *  A view used to display the caption for a photo.
 *
 *  This is used by default when no custom caption view is provided.
 */
@objc(NYTPhotoCaptionView)
public final class PhotoCaptionView: UIView, PhotoCaptionViewLayoutWidthHinting {
    private static let horizontalMargin: CGFloat = 8.0
    private static let vertialMargin: CGFloat = 7.0

    private let attributedTitle: NSAttributedString?
    private let attributedSummary: NSAttributedString?
    private let attributedCredit: NSAttributedString?

    private let textView = UITextView()
    private let gradientLayer = CAGradientLayer()

    // MARK: - UIView

    public override convenience init(frame: CGRect) {
        self.init(attributedTitle: nil, attributedSummary: nil, attributedCredit: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override class var requiresConstraintBasedLayout: Bool {
        true
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        let maxHeightConstraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .lessThanOrEqual,
            toItem: superview,
            attribute: .height,
            multiplier: 0.3,
            constant: 0,
        )
        superview?.addConstraint(maxHeightConstraint)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let safeAreaInsets = self.safeAreaInsets
        let selfBounds = layer.bounds
        gradientLayer.frame = CGRect(
            x: selfBounds.origin.x - safeAreaInsets.left,
            y: selfBounds.origin.y + safeAreaInsets.bottom,
            width: selfBounds.size.width + safeAreaInsets.left + safeAreaInsets.right,
            height: selfBounds.size.height + safeAreaInsets.bottom,
        )
    }

    public override var intrinsicContentSize: CGSize {
        let contentSize = textView.sizeThatFits(
            CGSize(width: preferredMaxLayoutWidth, height: .greatestFiniteMagnitude)
        )
        let width = preferredMaxLayoutWidth
        let height = ceil(contentSize.height)

        return CGSize(width: width, height: height)
    }

    public var preferredMaxLayoutWidth: CGFloat = 0 {
        didSet {
            preferredMaxLayoutWidth = ceil(preferredMaxLayoutWidth)
            if abs(oldValue - preferredMaxLayoutWidth) > 0.1 {
                invalidateIntrinsicContentSize()
            }
        }
    }

    // MARK: - NYTPhotoCaptionView

    /**
     *  Designated initializer that takes all the caption attributed strings as arguments.
     *
     *  @param attributedTitle   The attributed string used as the title.
     *                           The top string in the caption view.
     *  @param attributedSummary The attributed string used as the summary.
     *                           The second from the top string in the caption view.
     *  @param attributedCredit  The attributed string used as the credit.
     *                           The third from the top string in the caption view.
     */
    @objc
    public init(
        attributedTitle: NSAttributedString?,
        attributedSummary: NSAttributedString?,
        attributedCredit: NSAttributedString?,
    ) {
        self.attributedTitle = attributedTitle
        self.attributedSummary = attributedSummary
        self.attributedCredit = attributedCredit
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        setupTextView()
        updateTextViewAttributedText()
        setupGradient()
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.dataDetectorTypes = []
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(
            top: Self.vertialMargin,
            left: Self.horizontalMargin,
            bottom: Self.vertialMargin,
            right: Self.horizontalMargin,
        )
        addSubview(textView)

        let topConstraint = NSLayoutConstraint(
            item: textView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: 0,
        )
        let bottomConstraint = NSLayoutConstraint(
            item: textView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0,
        )
        let widthConstraint = NSLayoutConstraint(
            item: textView,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1,
            constant: 0,
        )
        let horizontalPositionConstraint = NSLayoutConstraint(
            item: textView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1,
            constant: 0,
        )
        addConstraints(
            [
                topConstraint,
                bottomConstraint,
                widthConstraint,
                horizontalPositionConstraint,
            ]
        )
    }

    private func setupGradient() {
        gradientLayer.frame = layer.bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.85).cgColor,
        ]
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func updateTextViewAttributedText() {
        let attributedLabelText = NSMutableAttributedString()

        if let attributedTitle {
            attributedLabelText.append(attributedTitle)
        }

        if let attributedSummary {
            if attributedTitle != nil {
                attributedLabelText.append(NSAttributedString(string: "\n"))
            }

            attributedLabelText.append(attributedSummary)
        }

        if let attributedCredit {
            if attributedTitle != nil || attributedSummary != nil {
                attributedLabelText.append(NSAttributedString(string: "\n"))
            }

            attributedLabelText.append(attributedCredit)
        }

        textView.attributedText = attributedLabelText
    }
}
