////
////  Bonus.swift
////  Breakout
////
////  Created by Out East on 28.08.2022.
////
//
//import Foundation
//import UIKit
//import SpriteKit
//
//// тут должен быть код с логикой бонусов когда - то
//enum BonusType2D: Int {
//    case addLive                 = 0
//    case increaseBallSpeed       = 1
//    case decreaseSpeedOfPaddle   = 2
//    case rotate                  = 3
//}
//struct Bonus2D {
//    // битовые маски различных игровых объектов
//    private let ballMask: UInt32           = 0b1 << 0 // 1
//    private let paddleMask: UInt32         = 0b1 << 1 // 2
//    private let brickMask: UInt32          = 0b1 << 2 // 4
//    private let bottomMask: UInt32         = 0b1 << 3 // 8
//    private let trajectoryBallMask: UInt32 = 0b1 << 4 // 16
//    private let frameMask: UInt32          = 0b1 << 5 // 32
//
//    /// node бонуса
//    var bonus: SKShapeNode
//    /// тип бонуса
//    var type: BonusType2D
//    /// цвет бонуса
//    /// в будущем хочу сделать разные цветовые схемы для уровней
//    var color: UIColor
//
//    /// позиция, где бонус появился
//    private var position: CGPoint
//
//
//
//    init(
//        frame: CGRect,
//        position: CGPoint
//    ) {
//
//        self.position = position
//        self.color = .white
//        let size = CGSize(width: 100, height: 100)
//
//        self.bonus = SKShapeNode(rectOf: size, cornerRadius: size.width/10.0)
//
//
//
//
//    }
//    /// с определенным шансом спавним бонус
//    func tryToAdd(to scene: SKScene) {
//        if random(border: 50) {
//            scene.addChild(bonus)
//
//            let bonusVelocity: CGFloat = 20.0
//            let timeToBottom = self.position.y/bonusVelocity
//
//            let moveAction = SKAction.move(to: CGPoint(x: self.position.x, y: 0.0), duration: timeToBottom)
//
//            self.bonus.run(moveAction)
//        }
//    }
//    /// задаем шанс, с которым может появиться бонус
//    /// сделано для того, чтобы бонусы разных типов могли появляться с разной частотой
//    private func random(border: Int) -> Bool {
//        let rand = Int.random(in: 0...border)
//        return rand == 0
//    }
//
//
//}
//// Идеи для бонусов -
//// увеличение количества жизней
//// переворот экрана с игрой
//// увеличение скорости мяча
//// замедление движения ракетки
//// увеличение урона мяча
//
