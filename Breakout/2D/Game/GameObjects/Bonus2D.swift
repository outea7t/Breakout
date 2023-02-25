//
//  Bonus.swift
//  Breakout
//
//  Created by Out East on 28.08.2022.
//

import Foundation
import UIKit
import SpriteKit

// тут должен быть код с логикой бонусов когда - то
enum BonusType2D: Int {
    case addLive
    case ballSpeed
    case slowerPaddle
    case rotation
}
struct Bonus2D {
    var bonus: SKShapeNode
    var type: BonusType2D
    var color: UIColor
    
    /// позиция, где бонус появился
    private var position: CGPoint
    private var shouldSpawn = false
    init(
        size: CGSize,
        frame: CGRect,
        position: CGPoint
    ) {
       
        self.position = position
        self.color = .white
        let decreasedSize = CGSize(width: size.width*0.8,
                                   height: size.height)
        self.bonus = SKShapeNode(rectOf: decreasedSize, cornerRadius: size.width/2)
        
        let rand = Int.random(in: 0...100)
        
        self.type = BonusType2D.addLive
        
    }
    
    
}
// Идеи для бонусов -
// увеличение количества жизней
// переворот экрана с игрой
// увеличение скорости мяча
// замедление движения ракетки
// увеличение урона мяча

