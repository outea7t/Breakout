//
//  ShopPaddleTexturesViewController.swift
//  Breakout
//
//  Created by Out East on 22.02.2023.
//

import UIKit

class ShopPaddleTexturesViewController: ShopParentViewController2D, TexturesShopController {
    var type = TypeOfShopController.paddle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = self.unselectedColor
        for i in 1...UserCustomization._2DmaxPaddleSkinIndex {
            let image = UIImage(named: "Paddle-\(i)")!
            let tempData = Shop2DCellData(image: image, price: 10, color: color, id: i-1, type: .ball)
            self.cellData.append(tempData)
        }
        
        if !UserCustomization._2DbuyedPaddleSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization._2DpaddleSkinIndex, section: 0)
        }
        // Do any additional setup after loading the view.
    }
    
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
