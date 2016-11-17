//
//  MVMediaManager.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 29/08/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AudioToolbox
import MediaPlayer

public let kMVMediaStartedPlaying = "kMVMediaStartedPlaying"
public let kMVMediaPausedPlaying = "kMVMediaPausedPlaying"
public let kMVMediaStopedPlaying = "kMVMediaStopedPlaying"
public let kMVMediaFinishedPlaying = "kMVMediaFinishedPlaying"
public let kMVMediaStartedBuffering = "kMVMediaStartedBuffering"
public let kMVMediaStopedBuffering = "kMVMediaStopedBuffering"
public let kMVMediaTimeUpdated = "kMVMediaTimeUpdated"
public let kMVMediaTimeStartedUpdating = "kMVMediaTimeStartedUpdating"
public let kMVMediaTimeFinishedUpdating = "kMVMediaTimeFinishedUpdating"

public let videoAutoHideTime: Double = 3

open class MVMediaManager: NSObject {
    
    open static let shared = MVMediaManager()
    
    open let avPlayer = AVPlayer()
    open var avPlayerLayer = AVPlayerLayer()
    open let notificationCenter = NotificationCenter()
    open var isPlayingLandscapeMedia = false
    open var playerIsPlaying: Bool {
        return avPlayer.rate > 0
    }
    
    /// Added to Solve play/pause rate issue
    fileprivate var playerLastRate: Float = 0.0
    
    fileprivate var playbackLikelyToKeepUpContext = 0
    fileprivate var playerRateBeforeSeek: Float = 0
    fileprivate var timeObserver: AnyObject?
    fileprivate var currentURL: URL?
    
    open static func isPlaying(_ url: URL?) -> Bool {
        if MVMediaManager.shared.avPlayer.rate == 0 {
            return false
        }
        
        if MVMediaManager.shared.currentURL == nil {
            return false
        }
        
        return MVMediaManager.shared.currentURL == url
    }
    
}

// MARK: - Events

extension MVMediaManager {
    
    public func prepareMedia(withUrl url: URL?, replaceCurrent: Bool = false, startPlaying: Bool = false) -> Bool {
        guard let url = url else {
            return false
        }
        
        //only plays if it's not playing the same url
        if avPlayer.rate == 0 || currentURL != url {
            currentURL = url
            
            //stream from url
            let playerItem = AVPlayerItem(url: url)
            avPlayer.replaceCurrentItem(with: playerItem)
        }
        avPlayerLayer.player = avPlayer
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        //Adds observers
        addBufferObserver()
        addTimeObserver()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MVMediaManager.didFinishPlaying(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
        
        //start playing right away if not a video as we want to improve it's quality before start playing
        if startPlaying {
            play()
        }
        
        return true
    }
    
    public func play(){
        if avPlayer.currentItem == nil {
            return
        }
        avPlayer.play()
        if playerLastRate > 1 {
            avPlayer.rate = playerLastRate
        }
        updateMediaInfo()
     
        notificationCenter.post(name: Notification.Name(rawValue: kMVMediaStartedPlaying), object: nil)
    }
    
    public func pause(){
        if avPlayer.currentItem == nil {
            return
        }
        
        playerLastRate = avPlayer.rate
        avPlayer.pause()
        
        notificationCenter.post(name: Notification.Name(rawValue: kMVMediaPausedPlaying), object: nil)
    }
    
    public func stop(){
        isPlayingLandscapeMedia = false
        
        if avPlayer.currentItem == nil {
            return
        }
        
        pause()
        
        //clear current URL
        currentURL = nil
        
        //removes remote controls
        removePlayerControls()
        
        notificationCenter.post(name: Notification.Name(rawValue: kMVMediaStopedPlaying), object: nil)
    }
    
    public func didFinishPlaying(_ sender: AnyObject){
        notificationCenter.post(name: Notification.Name(rawValue: kMVMediaFinishedPlaying), object: nil)
    }
    
    public func togglePlay(){
        if avPlayer.currentItem == nil {
            return
        }
        
        
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying {
            pause()
        } else {
            play()
        }
        
    }
    
    public func toggleRateSpeed() -> Float{
        if avPlayer.rate == 0 {
            return 1
        }
        
        if avPlayer.rate == 1 {
            avPlayer.rate = 1.25
        }else if avPlayer.rate == 1.25 {
            avPlayer.rate = 1.5
        }else if avPlayer.rate == 1.5 {
            avPlayer.rate = 2
        }else{
            avPlayer.rate = 1
        }
        
        return avPlayer.rate
    }
    
    // MARK: - Seek Slider Events
    
    public func sliderValueUpdated(_ timeSliderValue: Float){
        guard let currentItem = MVMediaManager.shared.avPlayer.currentItem else {
            return
        }
        notificationCenter.post(name: Notification.Name(rawValue: kMVMediaTimeUpdated), object: currentItem)
    }
    
    public func beginSeeking() {
        if avPlayer.currentItem == nil {
            return
        }
        
        playerRateBeforeSeek = avPlayer.rate
        pause()
    }
    
    public func endSeeking(_ timeSliderValue: Float) {
        guard let currentItem = avPlayer.currentItem else {
            return
        }
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(currentItem.elapsedTime(timeSliderValue), 100), completionHandler: { (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.play()
            }
        }) 
        
        notificationCenter.post(name: Notification.Name(rawValue: kMVMediaTimeFinishedUpdating), object: currentItem)
    }
    
    public func seek(addingSeconds seconds: Double){
        if avPlayer.currentItem == nil {
            return
        }
        
        let time = CMTimeMakeWithSeconds(CMTimeGetSeconds(avPlayer.currentTime()) + seconds, avPlayer.currentTime().timescale)
        avPlayer.currentItem?.seek(to: time)
    }
    
    public func seek(toTime time: Double){
        if avPlayer.currentItem == nil {
            return
        }
        
        avPlayer.currentItem?.seek(to: CMTime(seconds: time, preferredTimescale: avPlayer.currentTime().timescale))
    }
    
    public func currentTime() -> Double {
        if avPlayer.currentItem == nil {
            return 0
        }
        
        return avPlayer.currentItem!.currentTime().seconds
    }
    
    public func advance10(){
        seek(addingSeconds: 10)
    }
    
    public func rewind10(){
        seek(addingSeconds: -10)
    }
    
    public func seekRemotely(_ seekEvent: MPSeekCommandEvent){
        if (seekEvent.type == .beginSeeking) {
            print("Begin Seeking")
            //beginSeeking()
        }else if (seekEvent.type == .endSeeking) {
            print("End Seeking")
            //endSeeking(seekEvent.positionTime)
        }
    }
    
}


// MARK: - Time observer

extension MVMediaManager {
    
    fileprivate func removeTimeObserver(){
        if timeObserver != nil {
            MVMediaManager.shared.avPlayer.removeTimeObserver(timeObserver!)
            timeObserver?.invalidate()
            timeObserver = nil
        }
    }
    
    fileprivate func addTimeObserver(){
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = MVMediaManager.shared.avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
            //print("elapsedTime now:", CMTimeGetSeconds(elapsedTime))
            self.observeTime(elapsedTime)
        } as AnyObject?
        
    }
    
    fileprivate func observeTime(_ elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(MVMediaManager.shared.avPlayer.currentItem!.duration)
        if duration.isFinite {
            //            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            //            let timeRemaining: Float64 = duration - elapsedTime
            notificationCenter.post(name: Notification.Name(rawValue: kMVMediaTimeUpdated), object: nil)
        }
    }
}

// MARK: - Buffer observer

extension MVMediaManager {
    
    fileprivate func removeBufferObserver(){
        MVMediaManager.shared.avPlayer.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
    }
    
    fileprivate func addBufferObserver(){
        avPlayer.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: .new, context: &playbackLikelyToKeepUpContext)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &playbackLikelyToKeepUpContext {
            if MVMediaManager.shared.avPlayer.currentItem!.isPlaybackLikelyToKeepUp {
                notificationCenter.post(name: Notification.Name(rawValue: kMVMediaStopedBuffering), object: nil)
                updateMediaInfo()
            } else {
                notificationCenter.post(name: Notification.Name(rawValue: kMVMediaStartedBuffering), object: nil)
            }
        }
    }
    
}

// MARK: - Background Play

extension MVMediaManager {
    
    public func configBackgroundPlay(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }catch{
            print("Something went wrong creating audio session... \(error)")
            return
        }
        
        //controls
        addPlayerControls()
    }
    
    // MARK: - Player controls
    
    public func addPlayerControls(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        //play/pause
        commandCenter.pauseCommand.addTarget(self, action: #selector(MVMediaManager.pause))
        commandCenter.playCommand.addTarget(self, action: #selector(MVMediaManager.play))
        
        //seek forward
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekForwardCommand.addTarget(self, action: #selector(MVMediaManager.seekRemotely(_:)))
        
        //seek backward
        commandCenter.seekBackwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.addTarget(self, action: #selector(MVMediaManager.seekRemotely(_:)))
    }
    
    public func removePlayerControls(){
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    // MARK: - Media Info Art
    
    public var mediaInfo: [String: AnyObject]{
        get {
            let infoCenter = MPNowPlayingInfoCenter.default()
            
            if infoCenter.nowPlayingInfo == nil {
                infoCenter.nowPlayingInfo = [String: AnyObject]()
            }
            
            return infoCenter.nowPlayingInfo! as [String : AnyObject]
        }
        set{
            let infoCenter = MPNowPlayingInfoCenter.default()
            infoCenter.nowPlayingInfo = newValue
        }
    }
    
    public func addMediaInfo(_ author: String?, title: String?, coverImage: UIImage?){
        
        var nowPlayingInfo = mediaInfo
        
        if let author = author {
            nowPlayingInfo[MPMediaItemPropertyArtist] = author as AnyObject?
        }
        
        if let title = title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title as AnyObject?
        }
        
        if let coverImage = coverImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: coverImage)
        }
        
        mediaInfo = nowPlayingInfo
    }
    
    public func updateMediaInfo(_ item: AVPlayerItem? = MVMediaManager.shared.avPlayer.currentItem){
        if let item = item {
            var nowPlayingInfo = mediaInfo
            
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: CMTimeGetSeconds(item.currentTime()) as Double)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: CMTimeGetSeconds(item.duration) as Double)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: MVMediaManager.shared.avPlayer.rate as Float)
            
            mediaInfo = nowPlayingInfo
        }
    }
    
}
