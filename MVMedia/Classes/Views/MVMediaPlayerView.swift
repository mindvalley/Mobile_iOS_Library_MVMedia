//
//  MVMediaPlayerView.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 22/08/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AudioToolbox
import MediaPlayer

open class MVMediaPlayerView: UIView {
    
    open override func awakeFromNib() {
        self.layer.insertSublayer(MVMediaManager.shared.avPlayerLayer, at: 0)
    }
    
    open func prepareMedia(withUrl url: URL?, startPlaying: Bool = false) -> Bool {
        return MVMediaManager.shared.prepareMedia(withUrl: url, startPlaying: startPlaying)
    }
    
    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        MVMediaManager.shared.avPlayerLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    }
}

extension MVMediaPlayerView {
    
    public func play(){
        MVMediaManager.shared.play()
    }
    
    public func pause(){
        MVMediaManager.shared.pause()
    }
    
    public func stop(){
        MVMediaManager.shared.stop()
    }
    
    public func togglePlay(){
        MVMediaManager.shared.togglePlay()
    }
    
    public func toggleRateSpeed() -> Float{
        return MVMediaManager.shared.toggleRateSpeed()
    }
    
    public func rewind10(){
        MVMediaManager.shared.rewind10()
    }
    
    public func sliderValueUpdated(_ timeSliderValue: Float){
        MVMediaManager.shared.sliderValueUpdated(timeSliderValue)
    }
    
    public func beginSeeking() {
        MVMediaManager.shared.beginSeeking()
    }
    
    public func endSeeking(_ timeSliderValue: Float) {
        MVMediaManager.shared.endSeeking(timeSliderValue)
    }
    
    public func seek(addingSeconds seconds: Double){
        MVMediaManager.shared.seek(addingSeconds: seconds)
    }
    
    public func seek(toTime time: Double){
        MVMediaManager.shared.seek(toTime: time)
    }
    
    public func currentTime() -> Double{
        return MVMediaManager.shared.currentTime()
    }
    
    public func configBackgroundPlay() {
        MVMediaManager.shared.configBackgroundPlay()
    }
    
    public func addMediaInfo(_ author: String?, title: String?, coverImage: UIImage?) {
        MVMediaManager.shared.addMediaInfo(author, title: title, coverImage: coverImage)
    }
}

extension Float64 {
    public func formatedTime() -> String {
        return String(format: "%02d:%02d:%02d",
                      ((lround(self) / 3600) % 60),
                      ((lround(self) / 60) % 60),
                      lround(self) % 60
        )
    }
}

