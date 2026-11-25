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
        public static let didNavigateToPhoto =
            Notification.Name("NYTPhotosViewControllerDidNavigateToPhotoNotification")

        /**
         *  Notification name issued when this ``PhotosViewController`` is about to be
         *  dismissed.
         *
         *  Includes the ``PhotosViewController`` instance, as the notification's object.
         */
        public static let willDismiss =
            Notification.Name("NYTPhotosViewControllerWillDismissNotification")

        /**
         *  Notification name issued when this ``PhotosViewController`` has been
         *
         *  dismissed.
         *
         *  Includes the ``PhotosViewController`` instance, as the notification's object.
         */
        public static let didDismiss =
            Notification.Name("NYTPhotosViewControllerDidDismissNotification")

        public static let photoImageUpdated =
            Notification.Name("NYTPhotoViewControllerPhotoImageUpdatedNotification")
    }
}
