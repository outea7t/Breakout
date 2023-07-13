//
//  Ball.swift
//  Breakout
//
//  Created by Out East on 28.08.2022.
//

import UIKit
import SpriteKit


class Ball2D {
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
    private let bonusMask: UInt32          = 0b1 << 6 // 64
    private static var ballSkins = [BallSkin2D]()
    
    let ball: SKShapeNode
    let ballRadius: CGFloat
    
    var isAttachedToPaddle = true
    let constantBallVelocityLength: CGFloat = 800
    var lengthOfBallVelocityConstant: CGFloat = 800
    
    var particle: Particle2D
    private var lastParticleSpawnTime: TimeInterval = 0
    // знаменатель означает число частичек, которые будут появляться за 1 секунду
    var numberOfParticleConstant: CGFloat = 1/26
    init(frame: CGSize) {
        // настройка мяча
        // делаем размер мяча зависимым от размера экрана
        
        let ballRadius = 0.0513 * frame.width
        if frame.width > 700 && frame.height > 1000 {
            self.ball = SKShapeNode(rectOf: CGSize(width: ballRadius * 2 * 0.8, height: ballRadius * 2 * 0.8), cornerRadius: 0)
            self.ballRadius = ballRadius * 0.8
        } else {
            
            self.ball = SKShapeNode(rectOf: CGSize(width: ballRadius*2, height: ballRadius*2), cornerRadius: 0)
            //SKShapeNode(circleOfRadius: ballRadius)
            self.ballRadius = ballRadius
        }
        self.particle = Particle2D(ballRadius: ballRadius)
        
        self.ball.name = "ball"
        self.ball.position = CGPoint(x: 100.0, y: 100.0)
        self.ball.fillColor = #colorLiteral(red: 0.8, green: 0, blue: 1, alpha: 1)
        
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
    
    func update(paddle: SKShapeNode, currentTime: TimeInterval, gameNode: SKNode) {
        if self.isAttachedToPaddle {
            ball.physicsBody?.velocity = CGVector()
            ball.position = CGPoint(x: paddle.position.x,
                                         y: paddle.position.y + paddle.frame.size.height/2.0 + ball.frame.size.height/2.0)
        } else {
            self.updateCode(currentTime: currentTime, gameNode: gameNode)
        }
    }
    func update(currentTime: TimeInterval, gameNode: SKNode) {
        self.updateCode(currentTime: currentTime, gameNode: gameNode)
    }
    func collidedToBottom() {
        self.isAttachedToPaddle = true
    }
    func reset() {
        self.isAttachedToPaddle = true
    }
    func setBallSkin() {
        if !UserCustomization._2DbuyedBallSkinIndexes.isEmpty && UserCustomization._2DballSkinIndex < Ball2D.ballSkins.count {
            self.setSkinCode(skinIndex: UserCustomization._2DballSkinIndex)
        } else {
            print("error in set certain skin")
        }
    }
    func setCertainBallSkin(skinIndex: Int) {
        if skinIndex < Ball2D.ballSkins.count {
            setSkinCode(skinIndex: skinIndex)
        } else {
            print("error in set certain skin")
        }
    }
    
    static func initializeBallSkins() {
        print(UserCustomization._2DmaxBallSkinIndex)
        for i in 0..<(UserCustomization._2DmaxBallSkinIndex) {
            let textureImage = UIImage(named: "Ball-\(i+1)")
            if let textureImage = textureImage {
                let texture = SKTexture(image: textureImage)
                let ballSkin = BallSkin2D(fillColor: .white,
                                          strokeColor: .clear,
                                          lineWidth: 0,
                                          fillTexture: texture
                )
                
                self.ballSkins.append(ballSkin)
            }
        }
    }
    private func updateCode(currentTime: TimeInterval, gameNode: SKNode) {
        // добавляем к мячу частички
        if currentTime - self.lastParticleSpawnTime > self.numberOfParticleConstant {
            self.lastParticleSpawnTime = currentTime
            self.particle.addParticle(to: gameNode, ball: self)
        }
        // обновляем скорость мяча, чтобы она была постоянной
        if let currentBallVelocity = self.ball.physicsBody?.velocity {
            let simdVelocity = simd_float2(Float(currentBallVelocity.dx),
                                           Float(currentBallVelocity.dy))
            
            let normalizedVelocity = simd_normalize(simdVelocity)
            let newBallVelocity = CGVector(
                dx: Double(normalizedVelocity.x) * self.lengthOfBallVelocityConstant * 0.9,
                dy: Double(normalizedVelocity.y) * self.lengthOfBallVelocityConstant * 0.9)
            self.ball.physicsBody?.velocity = newBallVelocity
        }
    }
    private func setSkinCode(skinIndex: Int) {
        let currentBallSkin = Ball2D.ballSkins[skinIndex]
        self.ball.fillColor = currentBallSkin.fillColor
        self.ball.strokeColor = currentBallSkin.strokeColor
        self.ball.lineWidth = currentBallSkin.lineWidth
        if let ballFillTexture = currentBallSkin.fillTexture {
            self.ball.fillTexture = ballFillTexture
        }
    }
}

