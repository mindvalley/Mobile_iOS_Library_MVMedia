//
//  MVMediaTrackingDelegate.swift
//  Pods
//
//  Created by Evandro Harrison Hoffmann on 17/11/2016.
//
//

import UIKit

public enum MVMediaType: String{
    case video = "Video"
    case audio = "Audio"
}

public protocol MVMediaTrackingDelegate {
    
    func media(withType: MVMediaType, didChangeSpeedTo: Float)
    func media(withType: MVMediaType, didStopPlaying: Bool)
    func media(withType: MVMediaType, didStartPlaying: Bool)
    func media(withType: MVMediaType, didDownloadMedia: Bool)
    func media(withType: MVMediaType, didSelectMarker: MVMediaMarker)
    
}
