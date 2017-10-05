//
//  DragCloseViewController.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 30/08/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit

class DragCloseViewController: UIViewController {

    fileprivate var initialCenter = CGPoint(x: 0, y: 0)
    fileprivate var initialTouchPoint = CGPoint(x: 0, y: 0)
    fileprivate let distanceToClose: CGFloat = 100
    fileprivate let alphaAnimationTime: Double = 0.2
    
    var draggableView: UIView?
    var visibleWhileDraggingView: UIView?
    var frameFromPreviewView: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePan()
    }
    
    func configurePan(){
        let pan = UIPanGestureRecognizer(target:self, action:#selector(DragCloseViewController.pan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        self.draggableView?.addGestureRecognizer(pan)
    }
    
    @objc func pan(_ rec:UIPanGestureRecognizer) {
        
        guard let draggableView = draggableView else {
            return
        }
        
        let point: CGPoint = rec.location(in: self.view)
        let distance: CGPoint = CGPoint(x: point.x - initialTouchPoint.x, y: point.y - initialTouchPoint.y)
        
        switch rec.state {
        case .began:
            initialTouchPoint = point
            initialCenter = draggableView.center
            
            //fades everything but the visibleWhileDraggingView
            fadeSubviews(self.view, alpha: 0)
            fadeSuperviewBackground(draggableView, alpha: 0)
            
            draggableView.translatesAutoresizingMaskIntoConstraints = true
            break
        case .changed:
            draggableView.center.y = initialCenter.y + distance.y
            if draggableView.center.y < initialCenter.y {
                draggableView.center.y = initialCenter.y
            }
            break
        case .ended:
            if abs(distance.y) > distanceToClose {
                closeAnimated(distance)
            }else{
                //returns to initial configuration
                fadeSubviews(self.view, alpha: 1)
                fadeSuperviewBackground(draggableView, alpha: 1)
                self.view.backgroundColor = UIColor.clear
                draggableView.translatesAutoresizingMaskIntoConstraints = false
                
                UIView.animate(withDuration: 0.2, animations: {
                    draggableView.center = self.initialCenter
                })
            }
            break
        default:
            break
        }
    }
    
    func fadeSubviews(_ view: UIView, alpha: CGFloat){
        //if it's not the visibleWhileDraggingView, then simply fade
        if view != visibleWhileDraggingView {
            UIView.animate(withDuration: alphaAnimationTime, animations: {
                view.alpha = alpha
            })
        }
        
        //if there are no more subviews, stop
        if view.subviews.count == 0 {
            return
        }
        
        //go through all the subviews
        for subview in view.subviews {
            fadeSubviews(subview, alpha: alpha)
        }
    }
    
    func fadeSuperviewBackground(_ view: UIView, alpha: CGFloat){
        view.alpha = 1
        
        //fade background view
        //UIView.animateWithDuration(alphaAnimationTime, animations: {
            view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
        //})
        
        if let superview = view.superview {
            fadeSuperviewBackground(superview, alpha: alpha)
            return
        }
    }
    
    func dismiss(_ animated: Bool){
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: animated) {
                
            }
        }else{
            self.dismiss(animated: animated) {
                
            }
        }
    }
    
    func closeAnimated(_ distance: CGPoint){
        UIView.animate(withDuration: 0.2, animations: {
            if distance.y > 0 {
                self.draggableView!.center.y = self.view.frame.size.height+self.draggableView!.frame.size.height/2
            }else{
                self.draggableView!.center.y = -self.draggableView!.frame.size.height/2
            }
            
        }, completion: { (completed) in
            self.dismiss(false)
        })
    }
}
