//
//  NSBundle+NYTPhotoViewer.m
//  NYTPhotoViewer
//
//  Created by Chris Dzombak on 10/16/15.
//
//

import Foundation

extension Bundle {
    @objc // TODO: inline this property
    public static var nyt_photoViewerResourceBundle: Bundle {
        Bundle.module
    }
}
