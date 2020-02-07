//
//  SoftView.swift
//  Timers
//
//  Created by Danil Kurilo on 07.02.2020.
//  Copyright © 2020 Danil Kurilo. All rights reserved.
//

import UIKit

extension UIView {
    public func makeSoft() {
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize( width: 2, height: 2)
        self.layer.shadowColor = Constants.Colors.shadow.cgColor
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = bounds
        shadowLayer.backgroundColor = Constants.Colors.background.cgColor
        shadowLayer.shadowColor = UIColor.white.cgColor
        shadowLayer.cornerRadius = 15
        shadowLayer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 2
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
}
