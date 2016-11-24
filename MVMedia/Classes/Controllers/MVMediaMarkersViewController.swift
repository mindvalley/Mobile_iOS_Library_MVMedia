//
//  MediaMarkersViewController.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 19/09/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit

public protocol MVMediaMarkersViewControllerDelegate {
    func markerSelected(marker: MVMediaMarker)
}

open class MVMediaMarkersViewController: UIViewController {

    @IBOutlet open weak var closeButton: UIButton?
    @IBOutlet open weak var tableView: UITableView?
    @IBOutlet open weak var headerView: UIView?
    @IBOutlet open weak var headerTitle: UILabel?
    @IBOutlet open weak var contentView: UIView?
    
    open var mvMediaMarkersViewModel = MVMediaMarkersViewModel()
    open var delegate: MVMediaMarkersViewControllerDelegate?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareForAnimation()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - Animations
    
    open func prepareForAnimation(){
        closeButton?.alpha = 0
        contentView?.isHidden = true
    }
    
    open func animateIn(){
        let originalFrame = self.contentView?.frame ?? CGRect()
        
        contentView?.isHidden = false
        contentView?.frame.origin.x = self.view.frame.size.width
        
        UIView.animate(withDuration: 0.3, animations: {
            self.closeButton?.alpha = 1
            self.contentView?.frame = CGRect(origin: originalFrame.origin, size: CGSize(width: originalFrame.size.width+20, height: originalFrame.size.height))
            }) { (completed) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.contentView?.frame = originalFrame
                })
        }
    }
    
    open func animateOut(completion:@escaping ()->Void){
        UIView.animate(withDuration: 0.1, animations: {
            self.contentView?.transform = CGAffineTransform(scaleX: 1.1, y: 1)
        }) { (completed) in
            UIView.animate(withDuration: 0.2, animations: {
                self.closeButton?.alpha = 0
                self.contentView?.frame.origin.x = self.view.frame.size.width
                self.contentView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (completed) in
                completion()
            }
        }
    }

    // MARK: - Events
    
    @IBAction open func closeButtonPressed(_ sender: AnyObject) {
        animateOut{
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Panning
    
    fileprivate var initialCenter = CGPoint(x: 0, y: 0)
    fileprivate var initialTouchPoint = CGPoint(x: 0, y: 0)
    fileprivate let distanceToClose: CGFloat = 100
    fileprivate let alphaAnimationTime: Double = 0.2
    
    open func configurePan(){
        let pan = UIPanGestureRecognizer(target:self, action:#selector(DragCloseViewController.pan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        self.view.addGestureRecognizer(pan)
    }
    
    open func pan(_ rec:UIPanGestureRecognizer) {
        
        let point: CGPoint = rec.location(in: self.view)
        let distance: CGPoint = CGPoint(x: point.x - initialTouchPoint.x, y: point.y - initialTouchPoint.y)
        
        switch rec.state {
        case .began:
            initialTouchPoint = point
            initialCenter = contentView?.center ?? CGPoint()
            
            contentView?.translatesAutoresizingMaskIntoConstraints = true
            break
        case .changed:
            contentView?.center.x = initialCenter.x + distance.x
            
            //avoid going any further than the initial position to the left
            if contentView?.center.x ?? 0 < initialCenter.x {
                contentView?.center.x = initialCenter.x
            }
            
            closeButton?.alpha = 1-(distance.x/distanceToClose)
            
            break
        case .ended:
            if abs(distance.x) > distanceToClose {
                closeButtonPressed(self)
            }else{
                //returns to initial configuration
                contentView?.translatesAutoresizingMaskIntoConstraints = false
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.contentView?.center = self.initialCenter
                })
                
                closeButton?.alpha = 1
            }
            break
        default:
            break
        }
    }
    
}

extension MVMediaMarkersViewController: UITableViewDelegate, UITableViewDataSource{
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return mvMediaMarkersViewModel.sectionCount()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mvMediaMarkersViewModel.rowCount(section)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return mvMediaMarkersViewModel.cell(tableView, indexPath: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.markerSelected(marker: self.mvMediaMarkersViewModel.marker(forIndexPath: indexPath))
        self.animateOut {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
}
