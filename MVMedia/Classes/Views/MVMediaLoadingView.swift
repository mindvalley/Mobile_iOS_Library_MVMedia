//
//  LoadingView.swift
//  Micro Learning App
//
//  Created by Evandro Harrison Hoffmann on 10/08/2016.
//  Copyright © 2016 Mindvalley. All rights reserved.
//

import UIKit

extension UIView {
    
    func startMVMediaLoadingAnimationDelayed(_ delay: Double){
        let delayTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.startMVMediaLoadingAnimation()
        }
    }
    
    func startMVMediaLoadingAnimation(){
        stopMVMediaLoadingAnimation()
        
        let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loadingView.tintColor = UIColor.darkGray
        loadingView.center = self.center
        loadingView.startAnimating()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(loadingView)
        
        if #available(iOS 9.0, *) {
            loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
    }
    
    func stopMVMediaLoadingAnimation(){
        for subview in subviews{
            if let subview = subview as? UIActivityIndicatorView {
                subview.removeFromSuperview()
            }
        }
    }
}
