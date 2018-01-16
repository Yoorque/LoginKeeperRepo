//
//  BlurBackgroundView.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 12/23/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class BlurBackgroundView: NSObject {
    static func blurCurrent(view: UIView) {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = view.bounds
        view.addSubview(blurVisualEffectView)
    }
    
    static func removeBlurFrom(view: UIView) {
        for v in view.subviews {
            if v.isKind(of: UIVisualEffectView.self) {
                v.removeFromSuperview()
            }
        }
    }
}
