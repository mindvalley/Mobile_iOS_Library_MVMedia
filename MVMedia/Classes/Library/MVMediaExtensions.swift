//
//  MVMediaExtensions.swift
//  Pods
//
//  Created by Evandro Harrison Hoffmann on 18/11/2016.
//
//

import UIKit


extension UIView{
    
    func animateTouchDown(_ completion:(() -> Void)? = nil){
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.9
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { (Bool) in
            completion?()
            UIView .animate(withDuration: 0.2, animations: {
                self.alpha = 1
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (Bool) in
            })
        })
    }
    
}
