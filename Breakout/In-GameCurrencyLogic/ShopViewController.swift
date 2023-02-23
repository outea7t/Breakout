//
//  ShopViewController.swift
//  Breakout
//
//  Created by Out East on 31.12.2022.
//

import UIKit

class ShopViewController: UITabBarController, UITabBarControllerDelegate {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.selectedIndex = 0
        
        
        let backgroundColor = self.tabBar.backgroundColor
//        self.tabBar.layer.masksToBounds = false

        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = backgroundColor
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
        } else {
            tabBar.barTintColor = backgroundColor
         }
        
        self.tabBar.layer.cornerRadius = 40
        
        self.tabBar.layer.masksToBounds = true
        self.tabBar.shadowImage = UIImage()
        
//        self.tabBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
//        self.tabBar.layer.shadowOpacity = 1.0
//        self.tabBar.layer.shadowOffset = CGSize(width: 0.0,
//                                                height: -self.tabBar.frame.height/7.0)
//
//
//
//
//        self.tabBar.layer.shadowRadius = 10.0
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
