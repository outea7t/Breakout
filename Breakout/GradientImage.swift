//
//  GradientImage.swift
//  Breakout
//
//  Created by Out East on 27.01.2023.
//

import Foundation
import UIKit

/*
 Расширение класса UIImage для создания градиентовых изображений
 Для того, чтобы использовать их как текстуры со SpriteKit
 */
extension UIImage {
    static func gradientImage(with bounds: CGRect,
                              startPoint: CGPoint,
                              endPoint: CGPoint,
                              colors: [CGColor]
    ) -> UIImage? {
        
        let origin = CGPoint(x: 0, y: 0)
        let imageBounds = CGRect(x: origin.x, y: origin.y, width: bounds.width, height: bounds.height)
        
        // конфигурирем градиент
        let gradientLayer = CAGradientLayer()
        gradientLayer.bounds = imageBounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        // рендерим и создаем изображение градиента
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
