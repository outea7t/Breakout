//
//  Ball.swift
//  Breakout
//
//  Created by Out East on 28.08.2022.
//

import UIKit
import SpriteKit


struct Ball2D {
    private struct BallSkin2D {
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
    private var ballSkins = [BallSkin2D]()
    
    let ball: SKShapeNode
    let ballRadius: CGFloat
    
    var isAttachedToPaddle = true
    
    init(frame: CGRect) {
        // настройка мяча
        // делаем размер мяча зависимым от размера экрана
        
        let ballRadius = 0.0513 * frame.width
        if frame.width > 700 && frame.height > 1000 {
            self.ball = SKShapeNode(circleOfRadius: ballRadius * 0.8)
            self.ballRadius = ballRadius * 0.8
        } else {
            self.ball = SKShapeNode(circleOfRadius: ballRadius)
            self.ballRadius = ballRadius
        }
        self.initializeBallSkins()
        
        self.ball.name = "ball"
        self.ball.position = CGPoint(x: 100.0, y: 100.0)
        self.ball.fillColor = #colorLiteral(red: 0.8, green: 0, blue: 1, alpha: 1)
        self.ball.lineWidth = 3.0
        
        // физика
        self.ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        self.ball.physicsBody?.allowsRotation = false
        self.ball.physicsBody?.friction = 0.0
        self.ball.physicsBody?.linearDamping = 0.0
        self.ball.physicsBody?.restitution = 1.0
        // столкновения
        self.ball.physicsBody?.categoryBitMask = self.ballMask
        self.ball.physicsBody?.collisionBitMask = self.paddleMask | self.brickMask | self.bottomMask | self.frameMask
        self.ball.physicsBody?.contactTestBitMask = self.brickMask | self.frameMask | paddleMask
        
        
        self.setBallSkin()
    }
    
    func update(paddle: SKShapeNode) {
        if self.isAttachedToPaddle {
            ball.physicsBody?.velocity = CGVector()
            ball.position = CGPoint(x: paddle.position.x,
                                         y: paddle.position.y + paddle.frame.size.height/2.0 + ball.frame.size.height/2.0)
        } else {
//            if ball.physicsBody?.velocity.dx == 0 {
//                ball.physicsBody?.applyImpulse(CGVector(dx: 10.0, dy: 0.0))
//            } else if ball.physicsBody?.velocity.dy == 0 {
//                ball.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 10.0))
//            }
        }
    }
    
    mutating func collidedToBottom() {
        self.isAttachedToPaddle = true
    }
    mutating func reset() {
        self.isAttachedToPaddle = true
    }
    func setBallSkin() {
        if !UserCustomization.buyedBallSkinIndexes.isEmpty && UserCustomization.ballSkinIndex < self.ballSkins.count {
            let currentBallSkin = self.ballSkins[UserCustomization.ballSkinIndex]
            self.ball.fillColor = currentBallSkin.fillColor
            self.ball.strokeColor = currentBallSkin.strokeColor
            self.ball.lineWidth = currentBallSkin.lineWidth
            if let ballFillTexture = currentBallSkin.fillTexture {
                self.ball.fillTexture = ballFillTexture
            }
        }
    }
    private mutating func initializeBallSkins() {
        // 1
        let _1TextureImage = UIImage(named: "Ball-1")
        if let _1TextureImage {
            let _1Texture = SKTexture(image: _1TextureImage)
            let _1BallSkin = BallSkin2D(fillColor: .white,
                                        strokeColor: .clear,
                                        lineWidth: 0,
                                        fillTexture: _1Texture )
            
            self.ballSkins.append(_1BallSkin)
            
        }
        // 2
        let _2TextureImage = UIImage(named: "Ball-2")
        if let _2TextureImage {
            let _2Texture = SKTexture(image: _2TextureImage)
            let _2BallSkin = BallSkin2D(fillColor: .white,
                                        strokeColor: .clear,
                                        lineWidth: 0,
                                        fillTexture: _2Texture )
            
            self.ballSkins.append(_2BallSkin)
            
        }
        // 3
        let _3TextureImage = UIImage(named: "Ball-3")
        if let _3TextureImage {
            let _3Texture = SKTexture(image: _3TextureImage)
            let _3BallSkin = BallSkin2D(fillColor: .white,
                                        strokeColor: .clear,
                                        lineWidth: 0,
                                        fillTexture: _3Texture )
            
            self.ballSkins.append(_3BallSkin)
            
        }
        // 4
        let _4TextureImage = UIImage(named: "Ball-4")
        if let _4TextureImage {
            let _4Texture = SKTexture(image: _4TextureImage)
            let _4BallSkin = BallSkin2D(fillColor: .white,
                                        strokeColor: .clear,
                                        lineWidth: 0,
                                        fillTexture: _4Texture )
            
            self.ballSkins.append(_4BallSkin)
            
        }
        // 5
        let _5TextureImage = UIImage(named: "Ball-5")
        if let _5TextureImage {
            let _5Texture = SKTexture(image: _5TextureImage)
            let _5BallSkin = BallSkin2D(fillColor: .white,
                                        strokeColor: .clear,
                                        lineWidth: 0,
                                        fillTexture: _5Texture )
            
            self.ballSkins.append(_5BallSkin)
            
        }
        // 6
        let _6TextureImage = UIImage(named: "Ball-6")
        if let _6TextureImage {
            let _6Texture = SKTexture(image: _6TextureImage)
            let _6BallSkin = BallSkin2D(fillColor: .white,
                                        strokeColor: .clear,
                                        lineWidth: 0,
                                        fillTexture: _6Texture )
            
            self.ballSkins.append(_6BallSkin)
            
        }
        
    }
    
}

