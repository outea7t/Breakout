//
//  Paddle.swift
//  Breakout
//
//  Created by Out East on 28.08.2022.
//

import UIKit
import SpriteKit

struct Paddle2D {
    private struct PaddleSkin2D {
        var fillColor: UIColor
        var strokeColor: UIColor
        var lineWidth: CGFloat
        var fillTexture: SKTexture?
        var strokeTexture: SKTexture?
        
    }
    // битовые маски различных объектов
    private let ballMask: UInt32           = 0b1 << 0 // 1
    private let paddleMask: UInt32         = 0b1 << 1 // 2
    private let brickMask: UInt32          = 0b1 << 2 // 4
    private let bottomMask: UInt32         = 0b1 << 3 // 8
    private let trajectoryBallMask: UInt32 = 0b1 << 4 // 16
    private let frameMask: UInt32          = 0b1 << 5 // 32
    private let bonusMask: UInt32          = 0b1 << 6 // 64
    
    // скины для ракетки
    private static var paddleSkins = [PaddleSkin2D]()
    private let paddleYPosition: CGFloat = 40
    var paddle: SKShapeNode
    init(frame: CGRect) {
        // настройка ракетки
        // мы изменяем размер ракетки в зависимости от размера экрана
        // умножаем на литеральные константы (наверное плохо), но это нормально работает
        let paddleHeight: CGFloat = frame.height * 0.035
        let widthToHeightConstant: CGFloat = 10.0/3.0
        
        let paddleSize = CGSize(width: paddleHeight*widthToHeightConstant,
                                height: paddleHeight)
        let paddleCornerRadius = (paddleSize.width + paddleSize.height)/2.0 * 0.1818
        self.paddle = SKShapeNode(rectOf: paddleSize)
        self.paddle.position = CGPoint(x: frame.midX, y: self.paddleYPosition)
        self.paddle.fillColor = #colorLiteral(red: 0.06666666667, green: 0.05490196078, blue: 0.7607843137, alpha: 1)
        // физика
        self.paddle.physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
        self.paddle.physicsBody?.allowsRotation = false
        self.paddle.physicsBody?.friction = 0.0
        self.paddle.physicsBody?.linearDamping = 0.0
        self.paddle.physicsBody?.restitution = 1.0
        self.paddle.physicsBody?.isDynamic = false
        // столкновения
        self.paddle.physicsBody?.categoryBitMask = self.paddleMask
        self.paddle.physicsBody?.contactTestBitMask = self.ballMask | self.bonusMask
    }
    /// движение ракетки
    func move(by result: CGFloat) {
        self.paddle.position.x += result
    }
    /// перезагрузка позиции ракетки (устанавливаем ее в центр экрана)
    func reset(frame: CGRect) {
        self.paddle.position.x = frame.midX
    }
    /// проверяем, чтобы ракетка не выходила за границы экрана
    func paddleUpdate(frame: CGRect) {
        
        if self.paddle.position.x + self.paddle.frame.width/2.0 > frame.width {
            self.paddle.position = CGPoint(x: frame.width - self.paddle.frame.width/2.0,
                                           y: self.paddleYPosition)
        } else if self.paddle.position.x - self.paddle.frame.width/2.0 < 0.0 {
            self.paddle.position = CGPoint(x: self.paddle.frame.width/2.0,
                                           y: self.paddleYPosition)
        }

    }
    /// привязываем ракетку к центру, если мяч привязан к ней
    func boundToCenter(frame: CGRect) {
        self.paddle.position.x = frame.midX
    }
    
    func setPaddleSkin() {
        if !UserCustomization._2DbuyedPaddleSkinIndexes.isEmpty && UserCustomization._2DpaddleSkinIndex < Paddle2D.paddleSkins.count {
            let currentPaddleSkin = Paddle2D.paddleSkins[UserCustomization._2DpaddleSkinIndex]
            self.paddle.fillColor = currentPaddleSkin.fillColor
            self.paddle.strokeColor = currentPaddleSkin.strokeColor
            self.paddle.lineWidth = currentPaddleSkin.lineWidth
            if let paddleFillTexture = currentPaddleSkin.fillTexture {
                self.paddle.fillTexture = paddleFillTexture
            }
        }
    }
    static func initializePaddleSkins() {
        for i in 0..<(UserCustomization._2DmaxPaddleSkinIndex) {
            let textureImage = UIImage(named: "Paddle-\(i+1)")
            if let textureImage = textureImage {
                let texture = SKTexture(image: textureImage)
                let paddleSkin = PaddleSkin2D(fillColor: .white,
                                          strokeColor: .clear,
                                          lineWidth: 0,
                                          fillTexture: texture
                )
                
                Paddle2D.paddleSkins.append(paddleSkin)
            }
        }
       
        
    }
    
}
