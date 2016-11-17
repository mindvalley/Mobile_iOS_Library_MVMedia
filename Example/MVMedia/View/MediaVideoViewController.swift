//
//  MVVideoViewController.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 18/08/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit
import MVMedia

class MediaVideoViewController: MediaViewController {

    private var autoPlayTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mvMediaViewModel.hideCoverAfterStarted = true
        //coverImageView?.isHidden = true
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //start playing after a short delay so that the video quality is improved
        autoPlayTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MediaVideoViewController.startPlaying), userInfo: nil, repeats: false)
        
        setupAutoHideControlsTimer()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        autoPlayTimer?.invalidate()
        mediaPlayer?.stop()
    }
    
    // MARK: - Events
    
    func startPlaying(){
        mediaPlayer?.play()
        
        autoHideTimer?.invalidate()
        hideControls()
    }
    
}

// MARK: - MVMediaManager

extension MediaVideoViewController {
    
    override open func mediaStartedPlaying(_ notification: Notification) {
        super.mediaStartedPlaying(notification)
        
        setupAutoHideControlsTimer()
    }
    
    override open func mediaStopedPlaying(_ notification: Notification) {
        playButton?.isSelected = true
        autoHideTimer?.invalidate()
    }
    
    override open func mediaTimeHasUpdated(_ notification: Notification) {
        super.mediaTimeHasUpdated(notification)
        if mvMediaViewModel.seeking {
            autoHideTimer?.invalidate()
        }
    }
    
}
