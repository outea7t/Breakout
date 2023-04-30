//
//  Shop3DCollectionViewCell.swift
//  Breakout
//
//  Created by Out East on 27.04.2023.
//

import UIKit
import SceneKit

class Shop3DCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var priceLabel: UILabel!
    var model = SCNNode()
    var price: Int = 0
    var id: Int = -1
    var textureType: TextureType = .ball
    var data: Shop3DCellData?
    /// для анимирования размера и цвета ячейки
    private var viewPropertyAnimator: UIViewPropertyAnimator?
    private var selectionViewPropertyAnimator: UIViewPropertyAnimator?
    /// цвет, применяемый, когда ячейка невыбрана
    private let unselectedColor = #colorLiteral(red: 0.05882352941, green: 0.01568627451, blue: 0.1176470588, alpha: 1)
    /// цвет, применяемый, когда ячейка куплена, но не выбрана
    private let buyedColor = #colorLiteral(red: 0.3411764706, green: 0.1490196078, blue: 0.5843137255, alpha: 0.8)
    /// цвет, применяемый, когда ячейка выбрана
    let selectedColor = #colorLiteral(red: 0.2941176471, green: 0.09019607843, blue: 0.8823529412, alpha: 0.8)
    /// цвет рамки, которая появляется, когда мы выбираем ячейку
    let borderColor = #colorLiteral(red: 0.2862745098, green: 0.9960784314, blue: 0.4862745098, alpha: 1)
    /// размер рамки, которая появляется, когда мы выбираем рамку
    var borderWidth: CGFloat = 0.0
    
    func setup(with data: Shop3DCellData) {
        self.model = data.model
        self.price = data.price
        self.id = data.id
        self.textureType = data.textureType
        self.data = data
        
        self.priceLabel.layer.shadowOpacity = 1.0
        self.priceLabel.layer.shadowColor = #colorLiteral(red: 0.1125956997, green: 0.1019041017, blue: 0.2261445522, alpha: 1)
        self.priceLabel.layer.shadowOffset = CGSize(width: self.priceLabel.bounds.width/20.0,
                                                    height: self.priceLabel.bounds.height/20.0)
        self.priceLabel.layer.shadowRadius = 0.0
        self.priceLabel.clipsToBounds = false
        
        self.priceLabel.text = "\(self.price)"
        // считаем размер рамки (появляется, когда мы выбираем скин)
        self.borderWidth = CGFloat(self.bounds.width/12.5)
        
        self.model.position = SCNVector3(x: 0.0, y: 0.0, z: -0.175)
        self.model.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
        
        if !self.model.hasActions {
            let rotateAction = SCNAction.rotate(by: .pi/2, around: SCNVector3(0, 1, 0), duration: 2.0)
            let cycleRotating = SCNAction.repeatForever(rotateAction)
            self.model.runAction(cycleRotating)
        }
        
        let scene = SCNScene()
        self.scnView.scene = scene
        self.scnView.scene?.rootNode.addChildNode(self.model)
        
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = false
        camera.zNear = 0.001
        cameraNode.camera = camera
        
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        self.scnView.scene?.rootNode.addChildNode(cameraNode)
        
        let omniLightNode = SCNNode()
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.color = UIColor.white
        omniLight.intensity = 1000
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3(0.0, 0.5, -0.5)
        self.scnView.scene?.rootNode.addChildNode(omniLightNode)
        
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 700
        ambientLight.color = UIColor.white
        ambientLightNode.light = ambientLight
        self.scnView.scene?.rootNode.addChildNode(ambientLightNode)
        
        self.scnView.backgroundColor = self.unselectedColor
        
        self.backgroundColor = self.unselectedColor
        
        self.viewPropertyAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) {
            self.backgroundColor = self.selectedColor
            self.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        }
        self.selectionViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut)
        
        self.clipsToBounds = true
        self.layer.shadowOpacity = 0.0
        
        self.layer.shadowColor = #colorLiteral(red: 0.1557792425, green: 0.5071008801, blue: 0.2520245314, alpha: 0.7)
        let shadowSize = CGSize(width: self.bounds.width*1.15,
                                height: self.bounds.height*1.15)
        
        let xCoordinate = ((self.bounds.width - shadowSize.width) / 2)
        let yCoordinate = ((self.bounds.height - shadowSize.height) / 2)
        let shadowRect = CGRect(x: xCoordinate,
                                y: yCoordinate,
                                width: shadowSize.width,
                                height: shadowSize.height)
        
        
        
        self.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
        self.layer.shadowRadius = self.bounds.width/8
        self.layer.shadowOffset = .zero
        
    }
    // так как мы используем reusable cells то мы должны обнулять
    // некоторые косметические параметры для избежания багов
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.selectionViewPropertyAnimator = nil
        self.viewPropertyAnimator = nil
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
        self.layer.shadowOpacity = 0.0
        
        guard let rootNode = self.scnView.scene?.rootNode else {
            return
        }
        
        for child in rootNode.childNodes {
            child.removeFromParentNode()
        }
    }
    func select() {
        self.layer.borderColor = self.borderColor.cgColor
        self.backgroundColor = self.selectedColor
        self.layer.shadowOpacity = 1.0
        self.layer.borderWidth = self.bounds.width/12.5
    }
    func wasSelected() {
        self.selectionViewPropertyAnimator?.addAnimations {
            self.backgroundColor = self.selectedColor
            self.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2)
            self.layer.borderColor = self.borderColor.cgColor
            self.layer.borderWidth = self.borderWidth
            self.layer.shadowOpacity = 1.0
        }
        self.selectionViewPropertyAnimator?.addAnimations({
            self.transform = CGAffineTransform.identity
        }, delayFactor: 0.2)
        self.selectionViewPropertyAnimator?.startAnimation()
    }
    /// анимация, применяемая к ячейка, когда она перешла из выбранного в невыбранное состояние
    func wasUnselected(isBuyed: Bool) {
        self.viewPropertyAnimator?.addAnimations {
            if isBuyed {
                self.backgroundColor = self.buyedColor
            } else {
                self.backgroundColor = self.unselectedColor
            }
            self.transform = CGAffineTransform.identity
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0.0
            self.layer.shadowOpacity = 0.0
        }
        self.viewPropertyAnimator?.startAnimation()
    }
    func touchDown() {
        self.viewPropertyAnimator?.addAnimations {
            self.backgroundColor = self.selectedColor
            self.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            self.layer.borderColor = self.borderColor.cgColor
            self.layer.borderWidth = self.borderWidth
            self.layer.shadowOpacity = 1.0
        }
        self.viewPropertyAnimator?.startAnimation()
    }
    func resizeToIdentity() {
        self.viewPropertyAnimator?.addAnimations {
            self.transform = CGAffineTransform.identity
        }
        self.viewPropertyAnimator?.startAnimation()
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
