//
//  CosmicStyleSlider.swift
//  Breakout
//
//  Created by Out East on 03.06.2023.
//

import UIKit

class CosmicStyleSlider: UISlider {
    
    private let baseLayer = CALayer()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setup()
    }
    
    func setup() {
        
    }
}
