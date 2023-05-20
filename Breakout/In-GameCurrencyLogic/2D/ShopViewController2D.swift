//
//  ShopViewController.swift
//  Breakout
//
//  Created by Out East on 31.12.2022.
//

import UIKit
enum TypeOfShopController {
    case ball
    case paddle
    case particles
}
struct CellInfo {
    var frame: CGRect
    var borderWidth: CGFloat
    var borderColor: CGColor
    var cornerRadius: CGFloat
    var backgroundColor: UIColor
    var skinViewFrame: CGRect
}
protocol ShopCollectionViewCell: AnyObject, UIView {
    var id: Int {get}
    var priceLabel: UILabel! {get}
    var skinView: UIView! {get}
    var borderColor: UIColor {get}
    var borderWidth: CGFloat {get}
    var selectedColor: UIColor {get}
}
protocol TexturesShopController: AnyObject {
    var type: TypeOfShopController {get}
    var selectedCellIndexPath: IndexPath {get set}
    var selectedCellInfo: CellInfo? {get}
    var selectedCell: ShopCollectionViewCell? {get set}
    var actualPositionOfSelectedCell: CGPoint {get}
    var collectionView: UICollectionView! {get}
    var view: UIView! {get}
    func updateInfo()
}
protocol ShopViewController: AnyObject, UITabBarController {
    
}
class ShopViewController2D: UITabBarController, UITabBarControllerDelegate, ShopViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // чтобы цвет элементов не менялся в зависимости от темной или светлой темы телефона
        self.overrideUserInterfaceStyle = .dark
        self.delegate = self
        self.selectedIndex = 0
        self.tabBar.frame.size.height = self.view.bounds.height/10.0
        
        let barTintColor = #colorLiteral(red: 0.2549019608, green: 0.2549019608, blue: 0.2549019608, alpha: 0.3)
        let imageTintColor = #colorLiteral(red: 0.2862745098, green: 0.9960784314, blue: 0.4862745098, alpha: 1)
        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.selectionIndicatorTintColor = imageTintColor
            tabBarAppearance.backgroundColor = barTintColor
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
        } else {
            // background
            self.tabBar.barTintColor = barTintColor
            self.tabBar.tintColor = imageTintColor
         }
        self.tabBar.isTranslucent = true
        self.tabBar.layer.cornerRadius = self.tabBar.frame.height/4
        
        self.tabBar.layer.masksToBounds = true
        self.tabBar.shadowImage = UIImage()
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.animate(item: item)
    }
    
    private func animate(item: UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else {
            return
        }
        let timeInterval = 0.3
        let propertyAnimator = UIViewPropertyAnimator(duration: timeInterval, curve: .easeInOut) {
            barItemView.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6 )
        }
        
        propertyAnimator.addAnimations({barItemView.transform = .identity}, delayFactor: timeInterval)
        propertyAnimator.startAnimation()
    }
}
