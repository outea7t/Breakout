//
//  ShopParticlesViewController.swift
//  Breakout
//
//  Created by Out East on 09.01.2023.
//

import UIKit

class ShopParticlesTextureViewController: ShopParentViewController2D, TexturesShopController {
    
    var type = TypeOfShopController.particles
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = self.unselectedColor
        for i in 1...UserCustomization._2DmaxParticleSkinIndex {
            let image = UIImage(named: "Particle-\(i)")!
            let tempData = Shop2DCellData(image: image, price: 10, color: color, id: i-1, type: .ball)
            self.cellData.append(tempData)
        }
        
        
        if !UserCustomization._2DbuyedParticlesSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization._2DparticleSkinIndex, section: 0)
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
