# NYTPhotoViewer

NYTPhotoViewer is a slideshow and image viewer that includes double-tap to zoom, captions, support for multiple images, interactive flick to dismiss, animated zooming presentation, and more.

![Demo GIF](Documentation/photo_viewer.gif)

## Usage

Usage is simple, with the option for more complicated customization when needed through a delegate relationship. In the most basic implementation, just initialize the view controller with an array of photo objects and present it as normal:

```swift
let photosViewController = PhotosViewController(photos: photos)
self.present(photosViewController, animated: true)
```

## Installation

NYTPhotoViewer may be installed via Swift Package Manager, by pointing at this repo's URL.
## Requirements

This library requires a deployment target of iOS 15.0 or greater.

## Changelog

See [`CHANGELOG.md`](https://github.com/NYTimes/NYTPhotoViewer/blob/develop/CHANGELOG.md).
## Inspiration

NYTPhotoViewer draws feature inspiration from Facebook and Tweetbot’s image viewers.

## Implementation

NYTPhotoViewer has a straightforward implementation using standard UIKit components. The viewer is a `UIViewController` and uses `UIViewController` transitioning APIs for the animated and interactive transitions, a `UIPageViewController` for horizontal swiping between images, and `UIScrollView` for image zooming.

It is intended to be used without the need for subclassing, and as such it accepts model objects conforming to a `PhotoProtocol` and provides ample opportunity for customization via the `PhotosViewControllerDelegate`. Since standard APIs are used, the client has full control over the transitions and customization of the `PhotosViewController`.

## License

NYTPhotoViewer is available under the Apache 2.0 license. See [`LICENSE.md`](https://github.com/NYTimes/NYTPhotoViewer/blob/develop/LICENSE.md) for more information.

## Contributors

[A list of contributors is available through GitHub.](https://github.com/NYTimes/NYTPhotoViewer/graphs/contributors)
