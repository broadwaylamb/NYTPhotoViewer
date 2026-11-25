//
//  Notifications.swift
//  NYTPhotoViewer
//
//  Created by Sergej.Jaskiewicz on 25.11.2026.
//

import Foundation

extension Notification.Name {
    public enum NYTPhotoViewer {
        /**
         *  Notification name issued when this ``PhotosViewController`` navigates to
         *  a different photo.
         *
         *  Includes the ``PhotosViewController`` instance, as the notification's object.
         */
        public static let didNavigateToPhotoNotification =
            Notification.Name("NYTPhotosViewControllerDidNavigateToPhotoNotification")

        public static let didNavigateToInterstitialViewNotification =
            Notification.Name("NYTPhotosViewControllerDidNavigateToInterstitialViewNotification")

        /**
         *  Notification name issued when this ``PhotosViewController`` is about to be
         *  dismissed.
         *
         *  Includes the ``PhotosViewController`` instance, as the notification's object.
         */
        public static let willDismissNotification =
            Notification.Name("NYTPhotosViewControllerWillDismissNotification")

        /**
         *  Notification name issued when this ``PhotosViewController`` has been
         *
         *  dismissed.
         *
         *  Includes the ``PhotosViewController`` instance, as the notification's object.
         */
        public static let didDismissNotification =
            Notification.Name("NYTPhotosViewControllerDidDismissNotification")

        public static let photoImageUpdatedNotification =
            Notification.Name("NYTPhotoViewControllerPhotoImageUpdatedNotification")
    }
}
