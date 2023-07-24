//
//  ShopParticleTexturesViewController.swift
//  Breakout
//
//  Created by Out East on 26.04.2023.
//

import Foundation
import UIKit
import SceneKit

class ShopParticlesTexturesViewController3D: ShopParentViewController3D, TexturesShopController {
    
    var type = TypeOfShopController.particles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = self.unselectedColor
        for i in 1...UserCustomization._2DmaxParticleSkinIndex {
            let model = SCNScene(named: "Particle-\(i)")!.rootNode.childNode(withName: "Particle", recursively: true)!
            let tempData = Shop3DCellData(model: model, backgroundColor: color, price: 10, id: i-1, textureType: .particles)
            self.cellData.append(tempData)
        }
        if !UserCustomization._3DbuyedParticlesSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization._3DparticleSkinIndex, section: 0)
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
