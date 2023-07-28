//
//  ShopGameTextureViewController.swift
//  Breakout
//
//  Created by Out East on 27.07.2023.
//

import Foundation
import UIKit

class ShopGameTextureViewController2D: ShopParentViewController2D, TexturesShopController {
    var type: TypeOfShopController = .levelColorScheme
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let color = self.unselectedColor
        for i in 1...UserCustomization._2DmaxLevelColorSchemeIndex {
            let image = UIImage(named: "Frame-\(i)")!
            let tempData = Shop2DCellData(image: image, price: 10, color: color, id: i-1, type: .level)
            self.cellData.append(tempData)
        }
        
        if !UserCustomization._2DbuyedLevelColorSchemeIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization._2DlevelColorSchemeIndex, section: 0)
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
