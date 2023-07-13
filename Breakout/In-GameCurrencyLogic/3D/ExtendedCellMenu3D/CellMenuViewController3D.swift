//
//  CellMenuViewController3D.swift
//  Breakout
//
//  Created by Out East on 07.05.2023.
//

import UIKit
import SpriteKit
import SceneKit

class CellMenuViewController3D: UIViewController, ExtendedInfoCellViewController {
    var skinView: UIView {
        get {
            return self.skinModelView
        }
    }
    
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var cellInformationView: UIView!
    
    // объекты на экране с информацией о скине
    
    @IBOutlet weak var skinModelView: SCNView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var effectsLabel: UILabel!
    @IBOutlet weak var effectsInformationLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var moneyLabel: UILabel!
    
    var cellID: Int = 0
    var price: Int = 0
    var model = SCNNode()
    var typeOfCurrentShopController = TypeOfShopController.ball
    var isBuyed = false
    var shouldShowBuyButton: Bool = true
    
    private var backgroundAnimationScene: ExtendedCellMenuScene?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSceneView()
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
        
        
        self.cellInformationView.layer.cornerRadius = self.cellInformationView.frame.height/18
        
        self.skinModelView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.skinModelView.layer.shadowOffset = CGSize(width: self.skinModelView.bounds.width/10,
                                                       height: self.skinModelView.bounds.height/10)
        self.skinModelView.layer.shadowOpacity = 0.5
        self.skinModelView.layer.shadowRadius = self.skinModelView.bounds.width/10
        self.skinModelView.clipsToBounds = false
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let offsetX: CGFloat = 10
        let shadowPath = UIBezierPath(rect:
                                        CGRect(x: cellInformationView.bounds.origin.x - offsetX,
                                               y: cellInformationView.bounds.origin.y,
                                               width: cellInformationView.bounds.width + 2*offsetX,
                                               height: cellInformationView.bounds.height))
        self.cellInformationView.layer.shadowPath = shadowPath.cgPath
        self.cellInformationView.layer.shadowOffset = CGSize(width: 0.0, height: 20)
        self.cellInformationView.layer.shadowOpacity = 0.5
        self.cellInformationView.layer.shadowRadius = 10
    }
    
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        if GameCurrency.userMoney >= self.price {
            GameCurrency.userMoney -= self.price
            self.isBuyed = true
            if self.typeOfCurrentShopController == .ball {
                print("Ball")
                UserCustomization._3DbuyedBallSkinIndexes += [self.cellID]
                UserCustomization._3DballSkinIndex = self.cellID
            } else if self.typeOfCurrentShopController == .paddle {
                print("Paddle")
                UserCustomization._3DbuyedPaddleSkinIndexes += [self.cellID]
                UserCustomization._3DpaddleSkinIndex = self.cellID
            } else if self.typeOfCurrentShopController == .particles {
                print("Particle")
                UserCustomization._3DbuyedParticlesSkinIndexes += [self.cellID]
                UserCustomization._3DparticleSkinIndex = self.cellID
            }
            self.setParent()
            HapticManager.notificationVibrate(for: .success)
            self.dismiss(animated: true)
        } else {
            HapticManager.notificationVibrate(for: .error)
        }
    }
    func setParent() {
        guard let shopViewController = self.presentingViewController as? ShopViewController3D else {
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
    
    private func setupSceneView() {
        let scene = SCNScene()
        self.skinModelView.scene = scene
        
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = false
        camera.zNear = 0.001
        cameraNode.camera = camera
        
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        self.skinModelView.scene?.rootNode.addChildNode(cameraNode)
        
        let omniLightNode = SCNNode()
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.color = UIColor.white
        omniLight.intensity = 1000
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3(0.0, 0.15, 0.0)
        self.skinModelView.scene?.rootNode.addChildNode(omniLightNode)
        
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 700
        ambientLight.color = UIColor.white
        ambientLightNode.light = ambientLight
        self.skinModelView.scene?.rootNode.addChildNode(ambientLightNode)
        self.skinModelView.backgroundColor = UIColor.clear
        
        self.skinModelView.scene?.rootNode.addChildNode(self.model)
        
        
        if self.typeOfCurrentShopController == .particles {
            self.model.position = SCNVector3(x: 0.0, y: 0.0, z: -0.175)
        } else if self.typeOfCurrentShopController == .paddle {
            self.model.position = SCNVector3(x: 0.0, y: 0.0, z: -0.3)
        } else if self.typeOfCurrentShopController == .ball {
            self.model.position = SCNVector3(x: 0.0, y: 0.0, z: -0.05)
        }
        
        let rotateAction = SCNAction.rotate(by: .pi/2, around: SCNVector3(0, 1, 0), duration: 2.0)
        let cycleRotating = SCNAction.repeatForever(rotateAction)
//        model.runAction(cycleRotating)
        self.skinModelView.isUserInteractionEnabled = true
    }
}
extension CellMenuViewController3D: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionToExtendedCellMenu(animationDuration: 1.5, animationType: .present)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionToExtendedCellMenu(animationDuration: 1.5, animationType: .dismiss)
    }
    
}
