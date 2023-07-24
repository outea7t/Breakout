//
//  ShopBallTexturesViewController3D.swift
//  Breakout
//
//  Created by Out East on 26.04.2023.
//

import Foundation
import UIKit
import SceneKit

class ShopBallTexturesViewController3D: ShopParentViewController3D, TexturesShopController {
    
    var type: TypeOfShopController = .ball
    override func viewDidLoad() {
        super.viewDidLoad()
//        let model1 = SCNScene(named: "Ball-1")!.rootNode.childNode(withName: "Ball", recursively: true)!

        let color = self.unselectedColor
        for i in 1...UserCustomization._2DmaxBallSkinIndex {
            let model = SCNScene(named: "Ball-\(i)")!.rootNode.childNode(withName: "Ball", recursively: true)!
            let tempData = Shop3DCellData(model: model, backgroundColor: color, price: 10, id: i-1, textureType: .ball)
            self.cellData.append(tempData)
        }
        
        if !UserCustomization._3DbuyedBallSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization._3DballSkinIndex, section: 0)
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

