//
//  MVMedia.swift
//  Pods
//
//  Created by Evandro Harrison Hoffmann on 18/11/2016.
//
//

import UIKit

open class MVMedia: NSObject {

    static open func mediaViewController(withStoryboardName storyboardName: String, viewControllerName: String, mediaPath: String, coverImagePath: String? = nil, authorName: String? = nil, title: String? = nil, downloadPath: String? = nil, mediaMarkers: [MVMediaMarker]? = nil, previewing: Bool = false) -> UIViewController{
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: viewControllerName)
        
        if let viewcontroller = viewcontroller as? MVMediaViewController {
            viewcontroller.mvMediaViewModel.set(mediaPath: mediaPath, coverImagePath: coverImagePath, authorName: authorName, title: title, downloadPath: downloadPath, mediaMarkers: mediaMarkers)
            viewcontroller.isPreviewing = previewing
        }else if let navigationController = viewcontroller as? UINavigationController {
            if let viewcontroller = navigationController.viewControllers.first as? MVMediaViewController {
                viewcontroller.mvMediaViewModel.set(mediaPath: mediaPath, coverImagePath: coverImagePath, authorName: authorName, title: title, downloadPath: downloadPath, mediaMarkers: mediaMarkers)
                viewcontroller.isPreviewing = previewing
            }
        }
        
        return viewcontroller
    }
    
    static open func offlineFileDestination(withPath path: String?) -> URL? {
        guard let downloadPath = path else {
            return nil
        }
        
        guard let downloadUrl = URL(string: downloadPath) else {
            return nil
        }
        
        let documentsDirectoryURL =  FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL.appendingPathComponent(downloadUrl.lastPathComponent)
    }
    
}

extension UIViewController {
    
    open func openMedia(withStoryboardName storyboardName: String, viewControllerName: String, mediaPath: String, coverImagePath: String? = nil, authorName: String? = nil, title: String? = nil, downloadPath: String? = nil, mediaMarkers: [MVMediaMarker]? = nil) -> UIViewController?{
        
        let viewController = MVMedia.mediaViewController(withStoryboardName: storyboardName, viewControllerName: viewControllerName, mediaPath: mediaPath, coverImagePath: coverImagePath, authorName: authorName, title: title, downloadPath: downloadPath, mediaMarkers: mediaMarkers)
        
        if let navigationController = viewController as? UINavigationController {
            self.present(viewController, animated: false, completion: nil)
            
            return navigationController.viewControllers.first
        }
        
        //_ = self.navigationController?.pushViewController(viewController, animated: false)
        self.present(viewController, animated: false, completion: nil)
        return viewController
    }
    
}
