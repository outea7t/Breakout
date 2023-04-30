//
//  ShopBallTexturesViewController3D.swift
//  Breakout
//
//  Created by Out East on 26.04.2023.
//

import Foundation
import UIKit

class ShopBallTexturesViewController3D: UIViewController {
    
    override func viewDidLoad() {
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}
