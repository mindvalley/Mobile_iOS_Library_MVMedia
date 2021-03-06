//
//  MediaVideoNavigationViewController.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 04/10/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit

open class MVMediaLandscapeNavigationController: UINavigationController {

    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        becomePortrait()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignPortrait()
    }
    
    open func becomePortrait(){
        MVMediaManager.shared.isPlayingLandscapeMedia = true
        
        //to make sure it will rotate, trick it saying that it was in portrait before
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
    }
    
    open func resignPortrait() {
        MVMediaManager.shared.isPlayingLandscapeMedia = false
        
        //to make sure it will rotate, trick it saying that it was in landscape before
        UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }
    
}
