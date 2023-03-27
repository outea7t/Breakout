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
    case addLive                 = 0
    case increaseBallSpeed       = 1
    case decreaseSpeedOfPaddle   = 2
    case rotate                  = 3
    case maxValue                = 4
}
struct Bonus2D {
    // битовые маски различных игровых объектов
    private let ballMask: UInt32           = 0b1 << 0 // 1
    private let paddleMask: UInt32         = 0b1 << 1 // 2
    private let brickMask: UInt32          = 0b1 << 2 // 4
    private let bottomMask: UInt32         = 0b1 << 3 // 8
    private let trajectoryBallMask: UInt32 = 0b1 << 4 // 16
    private let frameMask: UInt32          = 0b1 << 5 // 32
    private let bonusMask: UInt32          = 0b1 << 6 // 64

    /// node бонуса
    var bonus: SKShapeNode
    /// тип бонуса
    var type: BonusType2D
    /// цвет бонуса
    /// в будущем хочу сделать разные цветовые схемы для уровней
    var color: UIColor

    /// позиция, где бонус появился
    private var position: CGPoint



    init(
        frame: CGRect,
        position: CGPoint
    ) {

        self.position = position
        self.color = .white
        let size = CGSize(width: 100, height: 100)

        self.bonus = SKShapeNode(rectOf: size, cornerRadius: 0)
        self.bonus.fillColor = .white
        self.bonus.strokeColor = .clear
        
        let rawBonusType = Int.random(in: 0..<BonusType2D.maxValue.rawValue)
        if let bonusType = BonusType2D(rawValue: rawBonusType) {
            self.type = bonusType
        } else {
            self.type = .addLive
        }
        
        switch self.type {
            case .addLive:
                self.bonus.fillTexture = SKTexture(imageNamed: "LiveBonus.png")
            case .increaseBallSpeed:
                self.bonus.fillTexture = SKTexture(imageNamed: "BallSpeedBonus.png")
//                self.bonus
            case .decreaseSpeedOfPaddle:
                self.bonus.fillTexture = SKTexture(imageNamed: "PaddleSpeedBonus.png")
            case .rotate:
                self.bonus.fillTexture = SKTexture(imageNamed: "RotateBonus.png")
            default:
                break
        }
        
        
        self.bonus.physicsBody = SKPhysicsBody(rectangleOf: self.bonus.frame.size)
        self.bonus.physicsBody?.affectedByGravity = false
        self.bonus.physicsBody?.allowsRotation = false
        self.bonus.physicsBody?.linearDamping = 0
        self.bonus.physicsBody?.friction = 0
        self.bonus.physicsBody?.categoryBitMask = self.bonusMask
        self.bonus.physicsBody?.collisionBitMask = self.paddleMask | self.bottomMask
        self.bonus.physicsBody?.contactTestBitMask = self.paddleMask | self.bottomMask
        
        self.bonus.position = self.position
        self.bonus.zPosition = -1
        
    }
    /// с определенным шансом спавним бонус
    /// возвращает true, если бонус появился
    /// false - если нет
    func tryToAdd(to scene: SKNode) -> Bool {
        if random(border: 2) {
            scene.addChild(bonus)
            // скорость бонуса
            let bonusVelocity: CGFloat = 150.0
            // расчитываем время относительно их расстояния до низа экрана, чтобы их скорость была одинаковой
            let timeToBottom = self.position.y / bonusVelocity
            print(timeToBottom)
            let moveAction = SKAction.move(to: CGPoint(x: self.position.x, y: 0.0), duration: timeToBottom)

            self.bonus.run(moveAction)
            
            return true
        }
        return false
    }
    func remove() {
        let resizeAction = SKAction.scale(to: 0.0, duration: 0.4)
        let sequence = SKAction.sequence([
            resizeAction,
            SKAction.removeFromParent()
        ])
        self.bonus.run(sequence)
    }
    
    /// задаем шанс, с которым может появиться бонус
    /// сделано для того, чтобы бонусы разных типов могли появляться с разной частотой
    private func random(border: Int) -> Bool {
        let rand = Int.random(in: 0...border)
        return rand == 0
    }

}
// Идеи для бонусов -
// увеличение количества жизней
// переворот экрана с игрой
// увеличение скорости мяча
// замедление движения ракетки
// увеличение урона мяча

