//
//  NYTViewController.swift
//  ios-photo-viewer
//
//  Created by Brian Capps on 02/11/2015.
//  Copyright (c) 2014 Brian Capps. All rights reserved.
//

import NYTPhotoViewer
import NYTPhotoViewerSwift
import UIKit

final class ViewController: UIViewController, PhotosViewControllerDelegate {
    @IBOutlet var imageButton: UIButton!
    private var dataSource: PhotoViewerArrayDataSource<ExamplePhoto>?

    @IBAction func imageButtonTapped(_ sender: Any?) {
        let dataSource = Self.newTimesBuildingDataSource()
        self.dataSource = dataSource

        let photosViewController = PhotosViewController(
            dataSource: dataSource,
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
        on photosViewController: PhotosViewController<ExamplePhoto>,
        afterDelayWith dataSource: PhotoViewerArrayDataSource<ExamplePhoto>,
    ) {
        if dataSource !== self.dataSource {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            for i in dataSource.photos.indices {
                if case .placeholder = dataSource.photos[i].state {
                    dataSource.photos[i].state = .loaded(UIImage(resource: .nyTimesBuilding))
                    dataSource.photos[i].attributedCaptionSummary = NSAttributedString(
                        string: "Photo which previously had a loading spinner (to see the spinner, reopen the photo viewer and scroll to this photo)",
                        attributes: [
                            .foregroundColor : UIColor.white,
                            .font : UIFont.preferredFont(forTextStyle: .body),
                        ]
                    )
                    photosViewController.updatePhoto(atIndex: i)
                }
            }
        }
    }

    // This method simulates completely swapping out the data source, after 10 seconds.
    private func switchDataSource(
        on photosViewController: PhotosViewController<ExamplePhoto>,
        afterDelayWith dataSource: PhotoViewerArrayDataSource<ExamplePhoto>,
    ) {
        if dataSource !== self.dataSource {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            let photoWithLongCaption = dataSource[.longCaption]!
            photosViewController.delegate = nil // delegate methods in this VC are intended for use with the TimesBuildingDataSource
            self.dataSource = Self.newVariedDataSource(including: photoWithLongCaption)
            photosViewController.dataSource = self.dataSource
            photosViewController.reloadPhotos(animated: true)
        }
    }

    // MARK: - PhotosViewController<ExamplePhoto>Delegate

    func photosViewController(
        _ photosViewController: PhotosViewController<ExamplePhoto>,
        referenceViewFor photo: ExamplePhoto
    ) -> UIView? {
        if photo == dataSource?[.noReferenceView] {
            return nil
        }

        return imageButton
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<ExamplePhoto>,
        loadingViewFor photo: ExamplePhoto
    ) -> UIView? {
        if photo == dataSource?[.customEverything] {
            let loadingLabel = UILabel()
            loadingLabel.text = "Custom Loading..."
            loadingLabel.textColor = .white
            return loadingLabel
        }

        return nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<ExamplePhoto>,
        captionViewFor photo: ExamplePhoto
    ) -> UIView? {
        if photo == dataSource?[.customEverything] {
            let label = UILabel()
            label.text = "Custom Caption View"
            label.textColor = .white
            label.backgroundColor = .red
            return label
        }

        return nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<ExamplePhoto>,
        maximumZoomScaleFor photo: ExamplePhoto
    ) -> CGFloat? {
        if photo == dataSource?[.customEverything] {
            return 0.5
        }

        return nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<ExamplePhoto>,
        titleFor photo: ExamplePhoto,
        atIndex photoIndex: Int,
        totalPhotoCount: Int?
    ) -> String? {
        if photo == dataSource?[.customEverything] {
            return "\(photoIndex + 1)/\(totalPhotoCount!)"
        }

        return nil
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<ExamplePhoto>,
        didNavigateTo photo: ExamplePhoto,
        atIndex photoIndex: Int
    ) {
        print("Did Navigate To Photo: \(photo) identifier: \(photoIndex)")
    }

    func photosViewController(
        _ photosViewController: PhotosViewController<ExamplePhoto>,
        actionCompletedWithActivityType activityType: UIActivity.ActivityType
    ) {
        print("Action Completed With Activity Type: \(String(describing: activityType))")
    }

    func photosViewControllerDidDismiss(_ photosViewController: PhotosViewController<ExamplePhoto>) {
        print("Did Dismiss Photo Viewer: \(photosViewController)")
    }

    // MARK: - Sample Data Sources

    private static func newTimesBuildingDataSource() -> PhotoViewerArrayDataSource<ExamplePhoto> {
        let photos = Photo.Index.allCases.map { i in
            let state: PhotoState =
                switch i {
                case .customEverything:
                    .placeholder(UIImage(resource: .nyTimesBuildingPlaceholder))
                case .defaultLoadingSpinner:
                    .none
                default:
                    .loaded(UIImage(resource: .nyTimesBuilding))
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

            return ExamplePhoto(
                index: i,
                state: state,
                attributedCaptionTitle: attributedTitle(from: String(i.rawValue + 1)),
                attributedCaptionSummary: attributedSummary(from: caption),
                attributedCaptionCredit: attributedCredit(from: "Photo: Nic Lehoux")
            )
        }

        return PhotoViewerArrayDataSource(photos: photos)
    }

    /// A second set of test photos, to demonstrate reloading the entire data source.
    private static func newVariedDataSource(including photo: ExamplePhoto) -> PhotoViewerArrayDataSource<ExamplePhoto> {
        var photo = photo
        photo.attributedCaptionTitle = nil
        photo.attributedCaptionSummary = attributedSummary(from: "This photo’s caption has changed in the data source.")
        let photos = [
            ExamplePhoto(
                index: .default,
                state: .loaded(UIImage(resource: .chess)),
                attributedCaptionTitle: attributedTitle(from: "Chess"),
                attributedCaptionCredit: attributedCredit(from: "Photo: Chris Dzombak"),
            ),
            photo
        ]

        return PhotoViewerArrayDataSource(photos: photos)
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
