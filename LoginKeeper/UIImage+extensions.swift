//
//  UIImage+extensions.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 2/11/18.
//  Copyright © 2018 Dusan Juranovic. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
