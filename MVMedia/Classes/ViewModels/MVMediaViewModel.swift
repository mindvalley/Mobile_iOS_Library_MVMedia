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
    open var mediaMarkers = [MVMediaMarker]()
    open var mediaType: MVMediaType?
    open var showHours = false
    
    func set(mediaPath: String, coverImagePath: String? = nil, authorName: String? = nil, title: String? = nil, downloadPath: String? = nil, mediaMarkers: [MVMediaMarker]? = nil, mediaType: MVMediaType = .video, showHours: Bool = false){
        self.mediaPath = mediaPath
        self.downloadPath = downloadPath
        self.title = title
        self.authorName = authorName
        self.coverImagePath = coverImagePath
        self.mediaType = mediaType
        self.showHours = showHours
        
        if let mediaMarkers = mediaMarkers {
            self.mediaMarkers = mediaMarkers
        }
    }
    
    open var offlineFileDestination: URL?{
        return MVMedia.offlineFileDestination(withPath: downloadPath)
    }
    
    open var mediaDownloadState: MVMediaDownloadState {
        if let offlineFileDestination = offlineFileDestination {
            if FileManager().fileExists(atPath: offlineFileDestination.path) {
                print("File is offline")
                return .downloaded
            }
        }
        
        return .streaming
    }
    
    open var mediaUrl: URL? {
        if mediaDownloadState == .downloaded {
            return offlineFileDestination
        }
        
        return mediaPath?.url
    }
    
    open var hideCoverAfterStarted = false
    open var seeking = false
    
    open func downloadMedia(_ success:@escaping ()->Void, failure:@escaping ()->Void){
        guard let downloadPath = downloadPath else {
            failure()
            return
        }
        
        guard let downloadUrl = URL(string: downloadPath) else {
            failure()
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
            URLSession.shared.downloadTask(with: downloadUrl, completionHandler: { (location, response, error) -> Void in
                guard let location = location , error == nil else {
                    failure()
                    return
                }
                
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
