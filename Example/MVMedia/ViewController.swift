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
                      mediaPath: "http://www.sample-videos.com/audio/mp3/india-national-anthem.mp3",
                      coverImagePath: "http://asalesguyrecruiting.com/wp-content/uploads/2015/07/Youre-Awesome.jpg",
                      authorName: "Mindvalley",
                      title: "You're awesome",
                      downloadPath: "http://www.sample-videos.com/audio/mp3/india-national-anthem.mp3")
    }
    
    @IBAction func playVideo(_ sender: Any) {
        _ = openMedia(withStoryboardName: "Media",
                      viewControllerName: "MediaVideoNavigation",
                      mediaPath: "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4",
                      coverImagePath: "http://asalesguyrecruiting.com/wp-content/uploads/2015/07/Youre-Awesome.jpg",
                      authorName: "Mindvalley",
                      title: "You're awesome",
                      downloadPath: "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4",
                      mediaMarkers: [MVMediaMarker(title: "First Marker", time: 1), MVMediaMarker(title: "Second Marker", time: 3)])
    }
}
