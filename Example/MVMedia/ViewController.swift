//
//  ViewController.swift
//  MVMedia
//
//  Created by Evandro Harrison Hoffmann on 17/11/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import MVMedia

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions

    @IBAction func playAudio(_ sender: Any) {
        _ = openMedia(withStoryboardName: "Media",
                      viewControllerName: "MediaAudio",
                      mediaPath: "http://www.stephaniequinn.com/Music/Allegro%20from%20Duet%20in%20C%20Major.mp3",
                      coverImagePath: "http://asalesguyrecruiting.com/wp-content/uploads/2015/07/Youre-Awesome.jpg",
                      authorName: "Mindvalley",
                      title: "You're awesome",
                      downloadPath: "http://www.stephaniequinn.com/Music/Allegro%20from%20Duet%20in%20C%20Major.mp3",
                      showHours: true)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        _ = openMedia(withStoryboardName: "Media",
                      viewControllerName: "MediaVideoNavigation",
                      mediaPath: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8",
                      coverImagePath: "http://asalesguyrecruiting.com/wp-content/uploads/2015/07/Youre-Awesome.jpg",
                      authorName: "Mindvalley",
                      title: "You're awesome",
                      downloadPath: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8",
                      mediaMarkers: [MVMediaMarker(title: "First Marker", time: 1), MVMediaMarker(title: "Second Marker", time: 3)])
    }
}
