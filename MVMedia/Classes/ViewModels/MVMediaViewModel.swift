//
//  VideoViewModel.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 18/08/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit

public enum MVMediaDownloadState {
    case downloading
    case downloaded
    case streaming
}

open class MVMediaViewModel: NSObject {
    
    open var title: String?
    open var mediaPath: String?
    open var downloadPath: String?
    open var coverImagePath: String?
    open var authorName: String?
    open var offlineAsset = false
    open var mediaMarkers = [MVMediaMarker]()
    
    func set(mediaPath: String, coverImagePath: String? = nil, authorName: String? = nil, title: String? = nil, downloadPath: String? = nil, hasOfflineAsset: Bool, mediaMarkers: [MVMediaMarker]? = nil){
        self.mediaPath = mediaPath
        self.downloadPath = downloadPath
        self.title = title
        self.authorName = authorName
        self.offlineAsset = hasOfflineAsset
        self.coverImagePath = coverImagePath
        
        if let mediaMarkers = mediaMarkers {
            self.mediaMarkers = mediaMarkers
        }
    }
    
    open var offlineFileDestination: URL?{
        guard let downloadPath = downloadPath else {
            return nil
        }
        
        guard let downloadUrl = URL(string: downloadPath) else {
            return nil
        }
        
        let documentsDirectoryURL =  FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL.appendingPathComponent(downloadUrl.lastPathComponent)
    }
    
    open var mediaDownloadState: MVMediaDownloadState {
        if offlineAsset {
            return .downloaded
        }
        
        return .streaming
    }
    
    open var hideCoverAfterStarted = false
    open var seeking = false
    
    open func downloadMedia(_ success:@escaping ()->Void, failure:@escaping ()->Void){
        guard let downloadPath = downloadPath else {
            return
        }
        
        guard let downloadUrl = URL(string: downloadPath) else {
            return
        }
        
        guard let offlineFileDestination = offlineFileDestination else {
            failure()
            return
        }
        
        // to check if it exists before downloading it
        if FileManager().fileExists(atPath: offlineFileDestination.path) {
            print("The file already exists at path")
            success()
        } else {
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: downloadUrl, completionHandler: { (location, response, error) -> Void in
                guard let location = location , error == nil else { return }
                do {
                    try FileManager().moveItem(at: location, to: offlineFileDestination as URL)
                    print("File moved to documents folder")
                    success()
                } catch let error as NSError {
                    print(error.localizedDescription)
                    failure()
                }
            }).resume()
        }
    }
}

extension String {
    
    public var url: URL? {
        return URL(string: self)
    }
    
}
