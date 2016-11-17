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
        self.layer.insertSublayer(MVMediaManager.sharedInstance.avPlayerLayer, at: 0)
    }
    
    open func playItem(withUrl url: URL?) -> Bool {
        return MVMediaManager.sharedInstance.playItem(withUrl: url)
    }
    
    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        MVMediaManager.sharedInstance.avPlayerLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    }
}

extension MVMediaPlayerView {
    
    public func play(){
        MVMediaManager.sharedInstance.play()
    }
    
    public func pause(){
        MVMediaManager.sharedInstance.pause()
    }
    
    public func stop(){
        MVMediaManager.sharedInstance.stop()
    }
    
    public func togglePlay(){
        MVMediaManager.sharedInstance.togglePlay()
    }
    
    public func toggleRateSpeed() -> Float{
        return MVMediaManager.sharedInstance.toggleRateSpeed()
    }
    
    public func rewind10(){
        MVMediaManager.sharedInstance.rewind10()
    }
    
    public func sliderValueUpdated(_ timeSliderValue: Float){
        MVMediaManager.sharedInstance.sliderValueUpdated(timeSliderValue)
    }
    
    public func beginSeeking() {
        MVMediaManager.sharedInstance.beginSeeking()
    }
    
    public func endSeeking(_ timeSliderValue: Float) {
        MVMediaManager.sharedInstance.endSeeking(timeSliderValue)
    }
    
    public func seek(addingSeconds seconds: Double){
        MVMediaManager.sharedInstance.seek(addingSeconds: seconds)
    }
    
    public func seek(toTime time: Double){
        MVMediaManager.sharedInstance.seek(toTime: time)
    }
    
    public func currentTime() -> Double{
        return MVMediaManager.sharedInstance.currentTime()
    }
    
    public func configBackgroundPlay() {
        MVMediaManager.sharedInstance.configBackgroundPlay()
    }
    
    public func addMediaInfo(_ author: String?, title: String?, coverImage: UIImage?) {
        MVMediaManager.sharedInstance.addMediaInfo(author, title: title, coverImage: coverImage)
    }
}

extension Float64 {
    public func formatedTime() -> String {
        return String(format: "%02d:%02d", ((lround(self) / 60) % 60), lround(self) % 60)
    }
}

