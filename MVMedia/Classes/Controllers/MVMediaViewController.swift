//
//  MediaViewController.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 18/08/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit
import AVFoundation

open class MVMediaViewController: UIViewController, MVMediaMarkersViewControllerDelegate {
    
    @IBOutlet open weak var contentView: UIView?
    @IBOutlet open weak var closeButton: UIBarButtonItem?
    @IBOutlet open weak var menuButton: UIBarButtonItem?
    @IBOutlet open weak var playButton: UIButton?
    @IBOutlet open weak var rewindButton: UIButton?
    @IBOutlet open weak var controlToggleButton: UIButton?
    @IBOutlet open weak var markersButton: UIButton?
    @IBOutlet open weak var minTimeLabel: UILabel?
    @IBOutlet open weak var maxTimeLabel: UILabel?
    @IBOutlet open weak var timeSlider: UISlider?
    @IBOutlet open weak var coverImageView: UIImageView?
    @IBOutlet open weak var bottomBarView: UIView?
    @IBOutlet open weak var titleLabel: UILabel?
    @IBOutlet open weak var speed2Button: UIButton?
    @IBOutlet open weak var minimizeButton: UIButton?
    @IBOutlet open weak var downloadView: UIView?
    @IBOutlet open weak var downloadLabel: UILabel?
    @IBOutlet open weak var downloadButton: UIButton?
    @IBOutlet open weak var mediaPlayer: MVMediaPlayerView?
    
    open var mvMediaViewModel = MVMediaViewModel()
    open var autoHideTimer: Timer?
    open var shouldSetupAutoHideControls = true
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.addTimeSliderActions()
        
        //sets the contentView to be draggable to close
        //draggableView = contentView
        //visibleWhileDraggingView = mediaPlayer
        
        self.titleLabel?.text = mvMediaViewModel.title
        
        //Configures Media player
        _ = mediaPlayer?.playItem(withUrl: mvMediaViewModel.mediaUrl)
        
        //configurates to play audio in background
        mediaPlayer?.configBackgroundPlay()
        
        //update download view state
        updateDownloadView(mvMediaViewModel.mediaDownloadState, animated: false)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareForAnimation()
        
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(false, animated: true)
        }
        
        //Add media observers
        addMediaObservers()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateIn()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observers
        removeMediaObservers()
    }
    
//    func closeAnimated(_ distance: CGPoint) {
//        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: self.coverImageView.frame.origin.x+distance.x, y: self.coverImageView.frame.origin.y+distance.y), size: self.coverImageView.frame.size))
//        imageView.contentMode = self.coverImageView.contentMode
//        imageView.image = self.coverImageView.image
//        imageView.layer.masksToBounds = true
//        view.addSubview(imageView)
//        
//        UIView.animate(withDuration: 0.2, animations: {
//            imageView.frame = self.frameFromPreviewView
//            }, completion: { (completed) in
//                self.dismiss(false)
//        })
//    }
    
    open func dismiss(_ animated: Bool){
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: animated) {
                
            }
        }else{
            self.dismiss(animated: animated) {
                
            }
        }
    }
    
// MARK: - Animations
    
    open func prepareForAnimation(){
        self.contentView?.alpha = 0
        self.contentView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    
    open func animateIn(){
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView?.alpha = 1
            self.contentView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { (completed) in
            UIView.animate(withDuration: 0.1, animations: {
                self.contentView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }) 
    }
    
    open func animateOut(_ completion:@escaping ()->Void){
        UIView.animate(withDuration: 0.1, animations: {
            self.contentView?.alpha = 1
            self.contentView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { (completed) in
            UIView.animate(withDuration: 0.2, animations: {
                self.contentView?.alpha = 0
                self.contentView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: { (completed) in
                completion()
            }) 
        }) 
    }
    
// MARK: - Controls
    
    open func setupAutoHideControlsTimer(){
        //hides control after start playing
        autoHideTimer = Timer.scheduledTimer(timeInterval: videoAutoHideTime, target: self, selector: #selector(MVMediaViewController.hideControls), userInfo: nil, repeats: false)
    }
    
    open func hideControls(){
        toggleControls(selected: NSNumber(value: true))
    }
    
    open func toggleControls(selected: NSNumber? = nil){
        if let selected = selected?.boolValue {
            self.controlToggleButton?.isSelected = selected
        }else{
            self.controlToggleButton?.isSelected = !(self.controlToggleButton?.isSelected ?? true)
        }
        
        self.navigationController?.setNavigationBarHidden(self.controlToggleButton?.isSelected ?? false, animated: true)
        
        if self.controlToggleButton?.isSelected ?? false {
            self.bottomBarView?.translatesAutoresizingMaskIntoConstraints = true
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomBarView?.frame.origin.y = self.view.frame.size.height
            })
        }else{
            self.bottomBarView?.translatesAutoresizingMaskIntoConstraints = true
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomBarView?.frame.origin.y = self.view.frame.size.height-(self.bottomBarView?.frame.size.height ?? 0)
            })
        }
    }
    
// MARK: - Cover Image
    
    open func finishedLoadingCoverImage(_ image: UIImage?){
        mediaPlayer?.addMediaInfo(mvMediaViewModel.authorName, title: mvMediaViewModel.title, coverImage: image )
    }
    
// MARK: - Events
    
    @IBAction open func menuButtonPressed(_ sender: AnyObject) {
    }
    
    @IBAction open func closeButtonPressed(_ sender: AnyObject) {
        animateOut {
            self.dismiss(false)
        }
    }
    
    @IBAction open func playButtonPressed(_ sender: AnyObject) {
        mediaPlayer?.togglePlay()
    }
    
    @IBAction open func rewindButtonPressed(_ sender: AnyObject) {
        mediaPlayer?.seek(addingSeconds: -10)
    }
    
    @IBAction open func markersButtonPressed(_ sender: AnyObject) {
       
    }
    
    @IBAction open func controlToggleButtonPressed(_ sender: AnyObject) {
        toggleControls()
    }
    
    @IBAction open func speed2ButtonPressed(_ sender: AnyObject) {
        if MVMediaManager.sharedInstance.avPlayer.rate == 0 {
            return
        }
        
        if let speed = mediaPlayer?.toggleRateSpeed() {
            speed2Button?.setTitle(String(format:"%.0fx", speed), for: .normal)
            if speed == 1.25 {
                speed2Button?.setTitle(String(format:"%.2fx", speed), for: .normal)
            }else if speed == 1.5 {
                speed2Button?.setTitle(String(format:"%.1fx", speed), for: .normal)
            }
        }
    }
    
// MARK: - Slider
    
    open func addTimeSliderActions(){
        timeSlider?.addTarget(self, action: #selector(timeSliderBeganTracking),
                             for: .touchDown)
        timeSlider?.addTarget(self, action: #selector(timeSliderEndedTracking),
                             for: [.touchUpInside, .touchUpOutside])
        timeSlider?.addTarget(self, action: #selector(timeSliderValueChanged),
                             for: .valueChanged)
    }
    
    @IBAction open func timeSliderValueChanged(_ sender: AnyObject) {
        if let value = timeSlider?.value {
            mediaPlayer?.sliderValueUpdated(value)
        }
    }
    
    @IBAction open func timeSliderBeganTracking(_ sender: AnyObject) {
        mvMediaViewModel.seeking = true
        mediaPlayer?.beginSeeking()
    }
    
    @IBAction open func timeSliderEndedTracking(_ sender: AnyObject) {
        mvMediaViewModel.seeking = false
        if let value = timeSlider?.value {
            mediaPlayer?.endSeeking(value)
        }
    }

// MARK: - MVMediaManager
    
    open func removeMediaObservers(){
        MVMediaManager.sharedInstance.notificationCenter.removeObserver(self)
    }
    
    open func addMediaObservers(){
        // Add observers
        MVMediaManager.sharedInstance.notificationCenter.addObserver(self, selector: #selector(MVMediaViewController.mediaStartedBuffering(_:)), name: NSNotification.Name(rawValue: kMVMediaStartedBuffering), object: nil)
        MVMediaManager.sharedInstance.notificationCenter.addObserver(self, selector: #selector(MVMediaViewController.mediaStopedBuffering(_:)), name: NSNotification.Name(rawValue: kMVMediaStopedBuffering), object: nil)
        MVMediaManager.sharedInstance.notificationCenter.addObserver(self, selector: #selector(MVMediaViewController.mediaStartedPlaying(_:)), name: NSNotification.Name(rawValue: kMVMediaStartedPlaying), object: nil)
        MVMediaManager.sharedInstance.notificationCenter.addObserver(self, selector: #selector(MVMediaViewController.mediaStopedPlaying(_:)), name: NSNotification.Name(rawValue: kMVMediaPausedPlaying), object: nil)
        MVMediaManager.sharedInstance.notificationCenter.addObserver(self, selector: #selector(MVMediaViewController.mediaFinishedPlaying(_:)), name: NSNotification.Name(rawValue: kMVMediaFinishedPlaying), object: nil)
        MVMediaManager.sharedInstance.notificationCenter.addObserver(self, selector: #selector(MVMediaViewController.mediaTimeHasUpdated(_:)), name: NSNotification.Name(rawValue: kMVMediaTimeUpdated), object: nil)
    }
    
    open func mediaTimeHasUpdated(_ notification: Notification) {
        if let currentItem = MVMediaManager.sharedInstance.avPlayer.currentItem {
            let duration = CMTimeGetSeconds(currentItem.duration)
            let currentTime = CMTimeGetSeconds(currentItem.currentTime())
            let remainingTime = duration - currentTime
            
            self.minTimeLabel?.text = currentTime.formatedTime()
            self.maxTimeLabel?.text = remainingTime.formatedTime()
            
            //only updates slider if not being called by the user on the slider
            if !mvMediaViewModel.seeking {
                timeSlider?.value = Float(currentTime / CMTimeGetSeconds(currentItem.duration))
            }else{
                autoHideTimer?.invalidate()
            }
        }
    }
    
    open func mediaStartedPlaying(_ notification: Notification) {
        playButton?.isSelected = false
    }
    
    open func mediaStopedPlaying(_ notification: Notification) {
        playButton?.isSelected = true
    }
    
    open func mediaStartedBuffering(_ notification: Notification) {
        
    }
    
    open func mediaStopedBuffering(_ notification: Notification) {
        
    }
    
    open func mediaFinishedPlaying(_ notification: Notification) {
        dismiss(true)
    }

// MARK: - Media Markers

    open func markerSelected(marker: MVMediaMarker) {
        mediaPlayer?.seek(toTime: marker.time)
    }
    
// MARK: - Download Events
    
    @IBAction open func downloadButtonPressed(_ sender: AnyObject) {
        self.updateDownloadView(.downloading, animated: true)
        self.mvMediaViewModel.downloadMedia({
            self.updateDownloadView(self.mvMediaViewModel.mediaDownloadState, animated: true)
        }, failure: {
            self.updateDownloadView(self.mvMediaViewModel.mediaDownloadState, animated: true)
        })
    }
    
    @IBAction open func minimizeButtonPressed(_ sender: AnyObject) {
        self.modalTransitionStyle = .coverVertical
        dismiss(true)
    }
    
    open func updateDownloadView(_ toState: MVMediaDownloadState, animated: Bool){
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.changeDownloadView(toState)
                self.downloadView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { (completed) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.downloadView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            })
        }else{
            changeDownloadView(toState)
        }
        
        //deactivate button if downloaded
        if toState == .downloaded {
            downloadButton?.isUserInteractionEnabled = false
        }
    }
    
    open func changeDownloadView(_ toState: MVMediaDownloadState){
        switch toState {
        case .streaming:
            downloadLabel?.text = ""
            downloadView?.backgroundColor = UIColor.clear
            downloadButton?.isSelected = false
            break
        case .downloading:
            downloadLabel?.text = "DOWNLOADING..."
            downloadView?.backgroundColor = UIColor.init(white: 0, alpha: 0.43)
            downloadButton?.isSelected = false
            break
        case .downloaded:
            downloadLabel?.text = "AVAILABLE OFFLINE"
            downloadView?.backgroundColor = UIColor.init(white: 0, alpha: 0.43)
            downloadButton?.isSelected = true
            
            break
        }
    }
}
