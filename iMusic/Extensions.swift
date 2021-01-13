//
//  Extensions.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import Foundation
import UIKit

extension UIImageView {
    /// Convertimos nuestra imagen en un círculo
    public func clipShapeCircle(image: UIImage) {
        self.contentMode = UIView.ContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        self.image = image
    }
}

