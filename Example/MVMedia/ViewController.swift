//
//  ViewController.swift
//  MVMedia
//
//  Created by Evandro Harrison Hoffmann on 17/11/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? MediaVideoNavigationController {
            // video
            if let viewController = navigationController.viewControllers.first as? MediaVideoViewController {
                viewController.mvMediaViewModel.authorName = "Mindvalley"
                viewController.mvMediaViewModel.coverImagePath = "http://asalesguyrecruiting.com/wp-content/uploads/2015/07/Youre-Awesome.jpg"
                viewController.mvMediaViewModel.title = "You're awesome"
                viewController.mvMediaViewModel.mediaUrl = URL(string: "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4")
                viewController.mvMediaViewModel.downloadUrl = URL(string: "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4")
                viewController.mvMediaViewModel.offlineAsset = false
            }
        }else if let viewController = segue.destination as? MediaViewController {
            // audio
            viewController.mvMediaViewModel.authorName = "Mindvalley"
            viewController.mvMediaViewModel.coverImagePath = "http://asalesguyrecruiting.com/wp-content/uploads/2015/07/Youre-Awesome.jpg"
            viewController.mvMediaViewModel.title = "You're awesome"
            viewController.mvMediaViewModel.mediaUrl = URL(string: "http://www.sample-videos.com/audio/mp3/india-national-anthem.mp3")
            viewController.mvMediaViewModel.downloadUrl = URL(string: "http://www.sample-videos.com/audio/mp3/india-national-anthem.mp3")
            viewController.mvMediaViewModel.offlineAsset = false
        }
    }

}
