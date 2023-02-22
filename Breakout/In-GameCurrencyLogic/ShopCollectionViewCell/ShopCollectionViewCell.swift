//
//  ShopCollectionViewCell.swift
//  Breakout
//
//  Created by Out East on 15.01.2023.
//

import UIKit

class ShopCollectionViewCell: UICollectionViewCell {
    /// картинка с текстурой
    @IBOutlet weak var imageView: UIImageView!
    /// лэйбл с ценой текстуры
    @IBOutlet weak var priceLabel: UILabel!
    /// цена
    var price: Int = 0
    
    /// для анимирования размера и цвета ячейки
    private var viewPropertyAnimator: UIViewPropertyAnimator?
    private var selectionViewPropertyAnimator: UIViewPropertyAnimator?
    /// цвет, применяемый, когда ячейка невыбрана
    private let unselectedColor = #colorLiteral(red: 0.05882352941, green: 0.01568627451, blue: 0.1176470588, alpha: 1)
    /// цвет, применяемый, когда ячейка куплена, но не выбрана
    private let buyedColor = #colorLiteral(red: 0.3411764706, green: 0.1490196078, blue: 0.5843137255, alpha: 0.8)
    /// цвет, применяемый, когда ячейка выбрана
    private let selectedColor = #colorLiteral(red: 0.2941176471, green: 0.09019607843, blue: 0.8823529412, alpha: 0.8)
    /// рамка, которая появляется, когда ячейка выбрана
    private var borderLayer: CAShapeLayer?
    private let borderColor = #colorLiteral(red: 0.2862745098, green: 0.9960784314, blue: 0.4862745098, alpha: 1)
    /// замена инициализатору
    func setup(with data: ShopCellData) {
        self.backgroundColor = data.color
        
        self.priceLabel.text = "\(data.price)"
        self.price = data.price
        self.priceLabel.layer.shadowOpacity = 1.0
        self.priceLabel.layer.shadowColor = #colorLiteral(red: 0.1125956997, green: 0.1019041017, blue: 0.2261445522, alpha: 1)
        self.priceLabel.layer.shadowOffset = CGSize(width: self.priceLabel.bounds.width/20.0,
                                                    height: self.priceLabel.bounds.height/20.0)
        self.priceLabel.layer.shadowRadius = 0.0
        self.priceLabel.clipsToBounds = false
        
        
        self.imageView.image = data.image
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.layer.shadowOpacity = 0.85
        self.imageView.layer.shadowColor = #colorLiteral(red: 0.111650534, green: 0.2205740809, blue: 0.3467395008, alpha: 0.598794495)
        self.imageView.layer.shadowOffset = CGSize(width: self.imageView.bounds.width/12.5,
                                                   height: self.imageView.bounds.height/12.5)
        self.imageView.layer.shadowRadius = 0
        
        self.imageView.clipsToBounds = false
        
        self.viewPropertyAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) {
            self.backgroundColor = self.selectedColor
            self.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        }
        self.selectionViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut)
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 30).cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = self.borderColor.withAlphaComponent(0.0).cgColor
        borderLayer.lineWidth = 20
        borderLayer.contentsCenter = CGRect(x: self.center.x,
                                            y: self.center.y,
                                            width: self.frame.width,
                                            height: self.frame.height)
        self.borderLayer = borderLayer
        self.layer.addSublayer(borderLayer)
        
    }
    func select() {
        self.borderLayer?.strokeColor = self.borderColor.cgColor
        self.backgroundColor = self.selectedColor
    }
    func wasSelected() {
        self.selectionViewPropertyAnimator?.addAnimations {
            self.backgroundColor = self.selectedColor
            self.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2)
            self.borderLayer?.strokeColor = self.borderColor.cgColor
        }
        self.selectionViewPropertyAnimator?.addAnimations({
            self.transform = CGAffineTransform.identity
        }, delayFactor: 0.2)
        self.selectionViewPropertyAnimator?.startAnimation()
    }
    func wasUnselected(isBuyed: Bool) {
        self.viewPropertyAnimator?.addAnimations {
            if isBuyed {
                self.backgroundColor = self.buyedColor
            } else {
                self.backgroundColor = self.unselectedColor
            }
            self.transform = CGAffineTransform.identity
            if let b = self.borderLayer {
                print("wasUnselected")
            }
            self.borderLayer?.strokeColor = self.borderColor.withAlphaComponent(0.0).cgColor
        }
        self.viewPropertyAnimator?.startAnimation()
    }
    func touchDown() {
        self.viewPropertyAnimator?.addAnimations {
            self.backgroundColor = self.selectedColor
            self.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            self.borderLayer?.strokeColor = #colorLiteral(red: 0.2862745098, green: 0.9960784314, blue: 0.4862745098, alpha: 1)
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
