//
//  ShopBallTexturesViewController.swift
//  Breakout
//
//  Created by Out East on 09.01.2023.
//

import UIKit

class ShopBallTexturesViewController: ShopParentViewController2D, TexturesShopController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userMoneyLabel.text = GameCurrency.updateUserMoneyLabel()
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
}
