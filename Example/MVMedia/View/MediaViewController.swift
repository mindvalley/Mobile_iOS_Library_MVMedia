//
//  MediaViewController.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 15/11/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit
import MVMedia

class MediaViewController: MVMediaViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
// MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? MediaMarkersViewController {
            viewController.mvMediaMarkersViewModel.currentTime = mediaPlayer?.currentTime() ?? 0
            viewController.mvMediaMarkersViewModel.markers = [MVMediaMarker(title: "First Marker", time: 1), MVMediaMarker(title: "Second Marker", time: 3)]
            viewController.delegate = self
        }
    }
}
