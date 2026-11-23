//
//  NYTViewController.swift
//  ios-photo-viewer
//
//  Created by Brian Capps on 02/11/2015.
//  Copyright (c) 2014 Brian Capps. All rights reserved.
//

import NYTPhotoViewer
import UIKit

final class ViewController: UIViewController, @MainActor NYTPhotosViewControllerDelegate {
    @IBOutlet var imageButton: UIButton!
    private var dataSource: NYTPhotoViewerArrayDataSource!

    enum PhotoIndex: Int, CaseIterable {
        case `default` = 0
        case customEverything
        case longCaption
        case defaultLoadingSpinner
        case noReferenceView
        case customMaxZoomScale
    }

    @IBAction func imageButtonTapped(_ sender: Any?) {
        dataSource = Self.newTimesBuildingDataSource()

        let photosViewController = NYTPhotosViewController(
            dataSource: dataSource,
            initialPhoto: nil,
            delegate: self,
        )

        present(photosViewController, animated: true)

        updateImages(on: photosViewController, afterDelayWith: dataSource)
        let demonstrateDataSourceSwitchAfterTenSeconds = false
        if demonstrateDataSourceSwitchAfterTenSeconds {
            switchDataSource(on: photosViewController, afterDelayWith: dataSource)
        }
    }

    private func updateImages(
        on photosViewController: NYTPhotosViewController,
        afterDelayWith dataSource: NYTPhotoViewerArrayDataSource,
    ) {
        if dataSource != self.dataSource {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            for photo in dataSource.photos {
                let photo = photo as! ExamplePhoto
                if photo.image == nil && photo.imageData == nil {
                    photo.image = UIImage(resource: .nyTimesBuilding)
                    photo.attributedCaptionSummary = NSAttributedString(
                        string: "Photo which previously had a loading spinner (to see the spinner, reopen the photo viewer and scroll to this photo)",
                        attributes: [
                            .foregroundColor : UIColor.white,
                            .font : UIFont.preferredFont(forTextStyle: .body),
                        ]
                    )
                    photosViewController.update(photo)
                }
            }
        }
    }

    // This method simulates completely swapping out the data source, after 10 seconds.
    private func switchDataSource(
        on photosViewController: NYTPhotosViewController,
        afterDelayWith dataSource: NYTPhotoViewerArrayDataSource,
    ) {
        if dataSource != self.dataSource {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            let photoWithLongCaption = dataSource[UInt(PhotoIndex.longCaption.rawValue)] as! ExamplePhoto
            photosViewController.delegate = nil // delegate methods in this VC are intended for use with the TimesBuildingDataSource
            self.dataSource = Self.newVariedDataSource(including: photoWithLongCaption)
            photosViewController.dataSource = self.dataSource
            photosViewController.reloadPhotos(animated: true)
        }
    }

    // MARK: - NYTPhotosViewControllerDelegate

    func photosViewController(
        _ photosViewController: NYTPhotosViewController,
        referenceViewFor photo: any NYTPhoto
    ) -> UIView? {
        if photo.isEqual(dataSource.photos[PhotoIndex.noReferenceView.rawValue]) {
            return nil
        }

        return imageButton
    }

    func photosViewController(
        _ photosViewController: NYTPhotosViewController,
        loadingViewFor photo: any NYTPhoto
    ) -> UIView? {
        if photo.isEqual(dataSource.photos[PhotoIndex.customEverything.rawValue]) {
            let loadingLabel = UILabel()
            loadingLabel.text = "Custom Loading..."
            loadingLabel.textColor = .white
            return loadingLabel
        }

        return nil
    }

    func photosViewController(
        _ photosViewController: NYTPhotosViewController,
        captionViewFor photo: any NYTPhoto
    ) -> UIView? {
        if photo.isEqual(dataSource.photos[PhotoIndex.customEverything.rawValue]) {
            let label = UILabel()
            label.text = "Custom Caption View"
            label.textColor = .white
            label.backgroundColor = .red
            return label
        }

        return nil
    }

    func photosViewController(
        _ photosViewController: NYTPhotosViewController,
        maximumZoomScaleFor photo: any NYTPhoto
    ) -> CGFloat {
        if photo.isEqual(dataSource.photos[PhotoIndex.customEverything.rawValue]) {
            return 0.5
        }

        return 1.0
    }

    func photosViewController(
        _ photosViewController: NYTPhotosViewController,
        titleFor photo: any NYTPhoto,
        at photoIndex: Int,
        totalPhotoCount: NSNumber?
    ) -> String? {
        if photo.isEqual(dataSource.photos[PhotoIndex.customEverything.rawValue]) {
            return "\(photoIndex + 1)/\(totalPhotoCount!.intValue)"
        }

        return nil
    }

    func photosViewController(
        _ photosViewController: NYTPhotosViewController,
        didNavigateTo photo: any NYTPhoto,
        at photoIndex: UInt
    ) {
        print("Did Navigate To Photo: \(photo) identifier: \(photoIndex)")
    }

    func photosViewController(
        _ photosViewController: NYTPhotosViewController,
        actionCompletedWithActivityType activityType: UIActivity.ActivityType?
    ) {
        print("Action Completed With Activity Type: \(String(describing: activityType))")
    }

    func photosViewControllerDidDismiss(_ photosViewController: NYTPhotosViewController) {
        print("Did Dismiss Photo Viewer: \(photosViewController)")
    }

    // MARK: - Sample Data Sources

    private static func newTimesBuildingDataSource() -> NYTPhotoViewerArrayDataSource {
        let photos = PhotoIndex.allCases.map { i in
            let photo = ExamplePhoto()

            if i == .customEverything || i == .defaultLoadingSpinner {
                // no-op, left here for clarity:
                photo.image = nil
            } else {
                photo.image = UIImage(resource: .nyTimesBuilding)
            }

            if i == .customEverything {
                photo.placeholderImage = UIImage(resource: .nyTimesBuildingPlaceholder)
            }

            let caption = switch i {
            case .default:
                "<photo summary>"
            case .customEverything:
                "Photo with custom everything"
            case .longCaption:
                "Photo with long caption.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum maximus laoreet vehicula. Maecenas elit quam, pellentesque at tempor vel, tempus non sem. Vestibulum ut aliquam elit. Vivamus rhoncus sapien turpis, at feugiat augue luctus id. Nulla mi urna, viverra sed augue malesuada, bibendum bibendum massa. Cras urna nibh, lacinia vitae feugiat eu, consectetur a tellus. Morbi venenatis nunc sit amet varius pretium. Duis eget sem nec nulla lobortis finibus. Nullam pulvinar gravida est eget tristique. Curabitur faucibus nisl eu diam ullamcorper, at pharetra eros dictum. Suspendisse nibh urna, ultrices a augue a, euismod mattis felis. Ut varius tortor ac efficitur pellentesque. Mauris sit amet rhoncus dolor. Proin vel porttitor mi. Pellentesque lobortis interdum turpis, vitae tincidunt purus vestibulum vel. Phasellus tincidunt vel mi sit amet congue."
            case .defaultLoadingSpinner:
                "Photo with loading spinner"
            case .noReferenceView:
                "Photo without reference view"
            case .customMaxZoomScale:
                "Photo with custom maximum zoom scale"
            }

            photo.attributedCaptionTitle = attributedTitle(from: String(i.rawValue + 1))
            photo.attributedCaptionSummary = attributedSummary(from: caption)
            photo.attributedCaptionCredit = attributedCredit(from: "Photo: Nic Lehoux")

            return photo
        }

        return NYTPhotoViewerArrayDataSource(photos: photos)
    }

    /// A second set of test photos, to demonstrate reloading the entire data source.
    private static func newVariedDataSource(including: ExamplePhoto) -> NYTPhotoViewerArrayDataSource {
        let photos: [ExamplePhoto] = [
            {
                let p = ExamplePhoto()
                p.image = UIImage(resource: .chess)
                p.attributedCaptionTitle = attributedTitle(from: "Chess")
                p.attributedCaptionCredit = attributedCredit(from: "Photo: Chris Dzombak")
                return p
            }(),
            {
                let p = ExamplePhoto()
                p.attributedCaptionTitle = nil
                p.attributedCaptionSummary = attributedSummary(from: "This photo’s caption has changed in the data source.")
                return p
            }(),
        ]

        return NYTPhotoViewerArrayDataSource(photos: photos)
    }

    private static func attributedTitle(from caption: String) -> NSAttributedString {
        NSAttributedString(
            string: caption,
            attributes: [
                .foregroundColor : UIColor.white,
                .font : UIFont.preferredFont(forTextStyle: .body),
            ]
        )
    }

    private static func attributedSummary(from summary: String) -> NSAttributedString {
        NSAttributedString(
            string: summary,
            attributes: [
                .foregroundColor : UIColor.lightGray,
                .font: UIFont.preferredFont(forTextStyle: .body),
            ]
        )
    }

    private static func attributedCredit(from credit: String) -> NSAttributedString {
        NSAttributedString(
            string: credit,
            attributes: [
                .foregroundColor : UIColor.gray,
                .font: UIFont.preferredFont(forTextStyle: .caption1),
            ]
        )
    }
}
