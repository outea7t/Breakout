//
//  ShopBallTexturesViewController.swift
//  Breakout
//
//  Created by Out East on 09.01.2023.
//

import UIKit

class ShopBallTexturesViewController: ShopParentViewController2D, TexturesShopController {

    public var type = TypeOfShopController.ball
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = self.unselectedColor
        for i in 1...UserCustomization._2DmaxBallSkinIndex {
            let image = UIImage(named: "Ball-\(i)")!
            let tempData = Shop2DCellData(image: image, price: 10, color: color, id: i-1, type: .ball)
            self.cellData.append(tempData)
        }
        
        if !UserCustomization._2DbuyedBallSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization._2DballSkinIndex, section: 0)
        }
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
