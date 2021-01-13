//
//  AppearanceCustom.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import Foundation
import UIKit

/// Customizamos la apariencia de nuestras views
struct AppearanceCustom {
    static func setCornerRadius(to view: UIView, cornerRadius: CGFloat) {
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }
    
    static func setShadow(to views: [UIView], shadowColor: CGColor, shadowOffset: CGSize, shadowRadius: CGFloat, shadowOpacity: Float) {
        for view in views {
            view.layer.shadowColor = shadowColor
            view.layer.shadowOffset = shadowOffset
            view.layer.shadowRadius = shadowRadius
            view.layer.shadowOpacity = shadowOpacity
            view.layer.masksToBounds = false
        }
    }
}
