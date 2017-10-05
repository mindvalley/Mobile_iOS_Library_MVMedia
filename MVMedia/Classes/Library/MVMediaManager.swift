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
    
    fileprivate var hasObserver = false,
    hasObserverMovie = false,
    onPause = false
    
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
    fileprivate var mediaType: MVMediaType?
    
    open static func isPlaying(_ url: URL?) -> Bool {
        if MVMediaManager.shared.avPlayer.rate == 0 {
            return false
        }
        
        if MVMediaManager.shared.currentURL == nil {
            return false
        }
        
        return MVMediaManager.shared.currentURL == url
    }
    
    public struct Constants {
        public static let kMVMediaCloseMediaView = "kMVMediaCloseMediaView"
    }
    
}

// MARK: - Events

extension MVMediaManager {
    
    // MARK: - Media Preparation
    
    public func prepareMedia(withUrl url: URL?, replaceCurrent: Bool = false, startPlaying: Bool = false, mediaType: MVMediaType?, seekTo: Double = 0) -> Bool {
        
        guard let url = url else {
            return false
        }
        
        self.mediaType = mediaType
        
        //only plays if it's not playing the same url
        print("rate \(avPlayer.rate)")
        
        print("readyToPlay: url: \(url)")
        
        if avPlayer.rate == 0 || currentURL != url {
            
            if let mediaType = mediaType, mediaType == .audio {
                
                print("readyToPlay: AUDIO")
                
                if currentURL == url {
                    play()
                } else {
                    let asset = AVAsset.init(url: url)
                    asset.loadValuesAsynchronously(forKeys: ["playable"] , completionHandler: {
                        
                        var error: NSError? = nil
                        let status = asset.statusOfValue(forKey: "playable", error: &error)
                        
                        switch status {
                        case .loaded:
                            self.loadAudioMedia(asset: asset, startPlaying: startPlaying, seekTo: seekTo)
                        default: break
                            // Handle all other cases
                        }
                        
                    })
                }
                
            } else {
                
                if currentURL == url {
                    
                    // play right away
                    self.addBufferObserverVideo()
                    self.bufferingFor(seconds: 0.5, andPlayAfterSeekingFor: -1)
                    
                } else {
                    
                    if url.pathExtension == "m3u8" {
                        
                        let asset = AVURLAsset.init(url: url)
                        asset.loadValuesAsynchronously(forKeys: ["playable"], completionHandler: {
                            
                            var error: NSError? = nil
                            let status = asset.statusOfValue(forKey: "playable", error: &error)
                            
                            switch status {
                            case .loaded:
                                self.loadVideoMedia(asset: asset, startPlaying: startPlaying, bufferTime: 0, seekTo: seekTo)
                            default: break
                                // Handle all other cases
                            }
                            
                        })
                        
                    } else {
                        
                        self.removeBufferObserverVideo()
                        
                        // stream from url
                        let playerItem = AVPlayerItem(url: url)
                        self.avPlayer.replaceCurrentItem(with: playerItem)
                        
                        self.avPlayerLayer.player = self.avPlayer
                        self.avPlayerLayer.videoGravity = UI_USER_INTERFACE_IDIOM() == .pad ?
                            AVLayerVideoGravity.resizeAspect : AVLayerVideoGravity.resizeAspectFill
                        
                        //Adds observers
                        self.addBufferObserver()
                        self.addTimeObserver()
                        
                        NotificationCenter.default.addObserver(
                            self,
                            selector: #selector(MVMediaManager.didFinishPlaying(_:)),
                            name: .AVPlayerItemDidPlayToEndTime,
                            object: self.avPlayer.currentItem
                        )
                        
                        bufferingFor(seconds: 1, andPlayAfterSeekingFor: seekTo)
                    }
                }
                
            }
            
            // update to the new url
            currentURL = url
        }
        
        return true
    }
    
    func loadAudioMedia(asset: AVAsset, startPlaying: Bool = false, seekTo: Double) {
        
        DispatchQueue.main.async {
            
            self.removeBufferObserverVideo()
            
            //stream from url
            let playerItem = AVPlayerItem.init(asset: asset)
            self.avPlayer.replaceCurrentItem(with: playerItem)
            
            self.avPlayerLayer.player = self.avPlayer
            self.avPlayerLayer.videoGravity = UI_USER_INTERFACE_IDIOM() == .pad ? AVLayerVideoGravity.resizeAspect : AVLayerVideoGravity.resizeAspectFill
            
            //Adds observers
            self.addBufferObserver()
            self.addTimeObserver()
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(MVMediaManager.didFinishPlaying(_:)),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: self.avPlayer.currentItem)
            
            if #available(iOS 10.0, *) {
                self.avPlayer.automaticallyWaitsToMinimizeStalling = false
                if let currentItem = self.avPlayer.currentItem {
                    currentItem.preferredPeakBitRate = 15
                    currentItem.preferredForwardBufferDuration = 200
                    currentItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                }
            }
            
            //start playing right away if not a video as we want to improve it's quality before start playing
            if startPlaying && self.avPlayer.rate == 0 {
                if seekTo > 0 {
                    self.seek(toTime: self.calcSeekTime(seekTime: seekTo))
                }
                self.play()
            }
        }
    }
    
    // When playing .m3u8 files we must prepare it differently
    func loadVideoMedia(asset: AVAsset, startPlaying: Bool = false, bufferTime: Double, seekTo: Double) {
        
        DispatchQueue.main.async {
            
            self.notificationCenter.post(name: Notification.Name(rawValue: kMVMediaStartedBuffering), object: nil)
            
            self.removeBufferObserverVideo()
            
            let playerItem = AVPlayerItem.init(asset: asset)
            self.avPlayer.replaceCurrentItem(with: playerItem)
            
            self.avPlayerLayer.player = self.avPlayer
            self.avPlayerLayer.videoGravity = UI_USER_INTERFACE_IDIOM() == .pad ?
                AVLayerVideoGravity.resizeAspect : AVLayerVideoGravity.resizeAspectFill
            
            //Adds observers
            self.addBufferObserverVideo()
            self.addTimeObserver()
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(MVMediaManager.didFinishPlaying(_:)),
                name: .AVPlayerItemDidPlayToEndTime,
                object: self.avPlayer.currentItem
            )
            
            if #available(iOS 10.0, *) {
                self.avPlayer.automaticallyWaitsToMinimizeStalling = false
                if let currentItem = self.avPlayer.currentItem {
                    currentItem.preferredPeakBitRate = 15
                    currentItem.preferredForwardBufferDuration = 200
                    currentItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                }
            }
            
            self.bufferingFor(seconds: bufferTime, andPlayAfterSeekingFor: seekTo)
            
            // resetting the preferredPeakBitRate and forcing another call on play()
            Timer.scheduledTimer(
                timeInterval: 2.3,
                target: self,
                selector: #selector(self.resetSync),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    @objc public func resetSync () {
        if let currentItem = MVMediaManager.shared.avPlayer.currentItem {
            currentItem.preferredPeakBitRate = 0
            play()
        }
    }
    
    @objc public func play(){
        
        if avPlayer.currentItem == nil {
            return
        }
        onPause = false
        avPlayer.play()
        
        if playerLastRate > 1 {
            avPlayer.rate = playerLastRate
        }
        updateMediaInfo()
        
        notificationCenter.post(name: Notification.Name(rawValue: kMVMediaStartedPlaying), object: nil)
    }
    
    @objc public func pause(){
        if avPlayer.currentItem == nil {
            return
        }
        
        onPause = true
        
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
        
        //removes remote controls
        removePlayerControls()
        
        notificationCenter.post(name: Notification.Name(rawValue: kMVMediaStopedPlaying), object: nil)
    }
    
    @objc public func didFinishPlaying(_ sender: AnyObject){
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
        onPause = false
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
    
    @objc public func seekRemotely(_ seekEvent: MPSeekCommandEvent){
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
    
    func removeBufferObserverVideo() {
        if hasObserverMovie {
            hasObserverMovie = false
            MVMediaManager.shared.avPlayer.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            MVMediaManager.shared.avPlayer.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
    }
    
    func addBufferObserverVideo() {
        if !hasObserverMovie {
            hasObserverMovie = true
            self.avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            self.avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        }
    }
    
    fileprivate func removeBufferObserver(){
        if hasObserver {
            hasObserver = false
            MVMediaManager.shared.avPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        }
    }
    
    fileprivate func addBufferObserver(){
        hasObserver = true
        MVMediaManager.shared.avPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playbackLikelyToKeepUpContext)
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
        
        guard keyPath != nil else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch keyPath! {
            
        case "playbackBufferEmpty" :
            
            if let item = avPlayer.currentItem, item.isPlaybackBufferEmpty, !onPause {
                print("readyToPlay: no buffer")
                // do something here to inform the user that the file is buffering
                notificationCenter.post(name: Notification.Name(rawValue: kMVMediaStartedBuffering), object: nil)
            }
            
        case "playbackLikelyToKeepUp" :
            
            if let item = avPlayer.currentItem, item.isPlaybackLikelyToKeepUp, !onPause {
                print("readyToPlay: ▶️")
                // remove the buffering inidcator if you added it
                self.play()
            }
            
        default:
            break
        }
        
    }
    
    func calcSeekTime(seekTime: Double) -> Double {
        if seekTime > 0 {
            if let currentItem = MVMediaManager.shared.avPlayer.currentItem {
                let sliderValue = Float(CMTimeGetSeconds(currentItem.asset.duration)) * Float.init(seekTime)
                if !sliderValue.isNaN {
                    return CMTimeGetSeconds(CMTimeMake(Int64(sliderValue), 1))
                }
            }
        }
        return 0
    }
    
    func bufferingFor(seconds: Double, andPlayAfterSeekingFor: Double) {
        // seek to paused point
        if andPlayAfterSeekingFor >= 0 {
            seek(toTime: calcSeekTime(seekTime: andPlayAfterSeekingFor))
        }
        // start playing after some buffer
        print("readyToPlay: bufferPlay \(seconds)")
        Timer.scheduledTimer(
            timeInterval: seconds,
            target: self,
            selector: #selector(play),
            userInfo: nil,
            repeats: false
        )
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
        // by now media info should only be shown for Audio
        if let item = item, mediaType == .audio {
            var nowPlayingInfo = mediaInfo
            
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: CMTimeGetSeconds(item.currentTime()) as Double)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: CMTimeGetSeconds(item.duration) as Double)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: MVMediaManager.shared.avPlayer.rate as Float)
            
            mediaInfo = nowPlayingInfo
        }
    }
    
    public func isPlaying() -> Bool {
        return avPlayer.rate != 0 && avPlayer.error == nil
    }
    
}
