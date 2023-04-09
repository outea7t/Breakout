//
//  CellMenuViewController.swift
//  Breakout
//
//  Created by Out East on 09.04.2023.
//

import UIKit

class CellMenuViewController: UIViewController {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var cellInformationView: UIView!
    
    // объекты на экране с информацией о скине
    @IBOutlet weak var skinImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var effectsLabel: UILabel!
    @IBOutlet weak var effectsInformationLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    var cellID: Int = 0
    var price: Int = 0
    var image = UIImage()
    var typeOfCurrentShopController = TypeOfShopController.ball
    override func viewDidLoad() {
        super.viewDidLoad()
        self.skinImageView.image = self.image
        self.priceLabel.text = "\(self.price)"
        self.effectsInformationLabel.text = "\u{2022} NONE \n\u{2022} NONE"
        
        self.buyButton.layer.cornerRadius = self.buyButton.frame.height/3
        self.buyButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.buyButton.layer.shadowOffset = CGSize(width: 0,
                                                   height: self.buyButton.frame.height/10.0)
        self.buyButton.layer.shadowOpacity = 0.5
        self.buyButton.layer.shadowRadius = self.buyButton.frame.height/10.0
        
        self.cellInformationView.layer.borderWidth = 10
        self.cellInformationView.layer.borderColor = UIColor.white.cgColor
        self.cellInformationView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let shadowPath = UIBezierPath(rect:
                                        CGRect(x: cellInformationView.bounds.origin.x-10,
                                               y: cellInformationView.bounds.origin.x,
                                               width: cellInformationView.bounds.width+20,
                                               height: cellInformationView.bounds.height))
        self.cellInformationView.layer.shadowPath = shadowPath.cgPath
        self.cellInformationView.layer.shadowOffset = CGSize(width: 0.0, height: 20)
        self.cellInformationView.layer.shadowOpacity = 0.5
        self.cellInformationView.layer.shadowRadius = 10
        
        self.cellInformationView.layer.cornerRadius = self.cellInformationView.frame.height/18
        
        self.skinImageView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.skinImageView.layer.shadowOffset = CGSize(width: self.skinImageView.bounds.width/10,
                                                       height: self.skinImageView.bounds.height/10)
        self.skinImageView.layer.shadowOpacity = 0.5
        self.skinImageView.layer.shadowRadius = self.skinImageView.bounds.width/10
        self.skinImageView.clipsToBounds = false
        // Do any additional setup after loading the view.
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self.view)
            if !self.cellInformationView.frame.contains(location) {
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        if GameCurrency.userMoney >= self.price {
            GameCurrency.userMoney -= self.price
            UserCustomization.buyedBallSkinIndexes += [self.cellID]
            UserCustomization.ballSkinIndex = self.cellID
            self.setParent()
            
            HapticManager.notificationVibrate(for: .success)
            self.dismiss(animated: true)
        } else {
            HapticManager.notificationVibrate(for: .error)
        }
    }
    func setParent() {
        guard let shopViewController = self.presentingViewController as? ShopViewController else {
            return
        }
        guard let childControllers = shopViewController.viewControllers else {
            return
        }
        for controller in childControllers {
            if let currentShopController = controller as? Textures2DShopController {
                if self.typeOfCurrentShopController == currentShopController.type {
                    let indexPath = IndexPath(item: self.cellID, section: 0)
                    currentShopController.selectedCellIndexPath = indexPath
                    currentShopController.updateInfo()
                }
            }
        }
    }
    
}
