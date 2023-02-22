//
//  Paddle.swift
//  Breakout
//
//  Created by Out East on 28.08.2022.
//

import UIKit
import SpriteKit

struct Paddle2D {
    // битовые маски различных объектов
    private let ballMask: UInt32    = 0b1 << 0 // 1
    private let paddleMask: UInt32  = 0b1 << 1 // 2
    private let brickMask: UInt32   = 0b1 << 2 // 4
    private let bottomMask: UInt32  = 0b1 << 3 // 8
    
    var paddle: SKShapeNode
    init(frame: CGRect) {
        // настройка ракетки
        // мы изменяем размер ракетки в зависимости от размера экрана
        // умножаем на литеральные константы (наверное плохо), но это нормально работает
        let paddleSize = CGSize(width: frame.width*0.26, height: frame.height*0.026)
        let paddleCornerRadius = (paddleSize.width + paddleSize.height)/2.0 * 0.1818
        self.paddle = SKShapeNode(rectOf: paddleSize, cornerRadius: paddleCornerRadius)
        
        self.paddle.position = CGPoint(x: frame.midX, y: 20.0)
        self.paddle.fillColor = #colorLiteral(red: 0.06666666667, green: 0.05490196078, blue: 0.7607843137, alpha: 1)
        self.paddle.lineWidth = 4
        self.paddle.strokeColor = .white
        // физика
        self.paddle.physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
        self.paddle.physicsBody?.allowsRotation = false
        self.paddle.physicsBody?.friction = 0.0
        self.paddle.physicsBody?.linearDamping = 0.0
        self.paddle.physicsBody?.restitution = 1.0
        self.paddle.physicsBody?.isDynamic = false
        // столкновения
        self.paddle.physicsBody?.categoryBitMask = self.paddleMask
        self.paddle.physicsBody?.contactTestBitMask = self.ballMask
        
    }
    /// движение ракетки
    func move(by result: CGFloat) {
        self.paddle.position = CGPoint(x: self.paddle.position.x + result,
                                       y: self.paddle.position.y)
    }
    /// перезагрузка позиции ракетки (устанавливаем ее в центр экрана)
    func reset(frame: CGRect) {
        self.paddle.position.x = frame.midX
        
    }
    /// проверяем, чтобы ракетка не выходила за границы экрана
    func paddleUpdate(frame: CGRect) {
        
        if self.paddle.position.x + self.paddle.frame.width/2.0 > frame.width {
            self.paddle.position = CGPoint(x: frame.width - self.paddle.frame.width/2.0,
                                      y: 20.0)
        } else if self.paddle.position.x - self.paddle.frame.width/2.0 < 0.0 {
            self.paddle.position = CGPoint(x: self.paddle.frame.width/2.0,
                                      y: 20.0)
        }

    }
    /// привязываем ракетку к центру, если мяч привязан к ней
    func boundToCenter(frame: CGRect) {
        self.paddle.position.x = frame.midX
    }
    
}
