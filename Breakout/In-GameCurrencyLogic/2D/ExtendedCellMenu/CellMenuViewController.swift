//
//  CellMenuViewController.swift
//  Breakout
//
//  Created by Out East on 09.04.2023.
//

import Foundation
import UIKit
import SpriteKit

class CellMenuViewController: UIViewController, ExtendedInfoCellViewController {
    var skinView: UIView {
        get {
            return self.skinImageView
        }
    }
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var cellInformationView: UIView!
    
    // объекты на экране с информацией о скине
    @IBOutlet weak var skinImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var effectsLabel: UILabel!
    @IBOutlet weak var effectsInformationLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var moneyLabel: UILabel!
    
    var cellID: Int = 0
    var price: Int = 0
    var image = UIImage()
    var typeOfCurrentShopController = TypeOfShopController.ball
    var isBuyed = false
    var shouldShowBuyButton: Bool = true
    
    private var backgroundAnimationScene: ExtendedCellMenuScene?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.skinImageView.image = self.image
        self.priceLabel.text = "\(self.price)"
        self.effectsInformationLabel.text = "\u{2022} NONE \n\u{2022} NONE"
        
        if let text = self.effectsInformationLabel.text {
            self.effectsInformationLabel.textAlignment = .center
            let attributedText = NSMutableAttributedString(string: text)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            self.effectsInformationLabel.attributedText = attributedText
        }
        
        if self.shouldShowBuyButton {
            self.buyButton.isHidden = false
            self.buyButton.layer.cornerRadius = self.buyButton.frame.height/3
            self.buyButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.buyButton.layer.shadowOffset = CGSize(width: 0,
                                                       height: self.buyButton.frame.height/10.0)
            self.buyButton.layer.shadowOpacity = 0.5
            self.buyButton.layer.shadowRadius = self.buyButton.frame.height/10.0
        } else {
            self.buyButton.isHidden = true
        }
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
        self.moneyLabel.text = GameCurrency.updateUserMoneyLabel()
        
        if let spriteKitView = self.view.viewWithTag(1) as? SKView {
            spriteKitView.backgroundColor = .clear
            let scene = ExtendedCellMenuScene(size: spriteKitView.frame.size)
            scene.scaleMode = .aspectFill
            scene.backgroundColor = .clear
            
            spriteKitView.presentScene(scene)
            scene.removeAllActions()
            scene.removeAllChildren()
            
            self.backgroundAnimationScene = scene
            
            spriteKitView.showsFPS = true
            spriteKitView.showsNodeCount = true
        }
        self.transitioningDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    @objc func didEnterBackground() {
        self.backgroundAnimationScene?.pause()
    }
    @objc func willEnterForeground() {
        self.backgroundAnimationScene?.unpause()
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
            self.isBuyed = true
            if self.typeOfCurrentShopController == .ball {
                UserCustomization._2DbuyedBallSkinIndexes += [self.cellID]
                UserCustomization._2DballSkinIndex = self.cellID
            } else if self.typeOfCurrentShopController == .paddle {
                UserCustomization._2DbuyedPaddleSkinIndexes += [self.cellID]
                UserCustomization._2DpaddleSkinIndex = self.cellID
            } else if self.typeOfCurrentShopController == .particles {
                UserCustomization._2DbuyedParticlesSkinIndexes += [self.cellID]
                UserCustomization._2DparticleSkinIndex = self.cellID
            }
            self.setParent()
            HapticManager.notificationVibrate(for: .success)
            self.dismiss(animated: true)
        } else {
            HapticManager.notificationVibrate(for: .error)
        }
    }
    func setParent() {
        guard let shopViewController = self.presentingViewController as? ShopViewController2D else {
            return
        }
        guard let childControllers = shopViewController.viewControllers else {
            return
        }
        for controller in childControllers {
            if let currentShopController = controller as? TexturesShopController {
                if self.typeOfCurrentShopController == currentShopController.type {
                    let indexPath = IndexPath(item: self.cellID, section: 0)
                    currentShopController.selectedCellIndexPath = indexPath
                    currentShopController.updateInfo()
                }
            }
        }
    }
    
}
extension CellMenuViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionToExtendedCellMenu(animationDuration: 1.5, animationType: .present)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionToExtendedCellMenu(animationDuration: 1.5, animationType: .dismiss)
    }
    
}
