//
//  Particle.swift
//  Breakout
//
//  Created by Out East on 28.08.2022.
//

import Foundation
import UIKit
import SpriteKit

struct ParticleSkin2D {
    var fillColor: UIColor
    var strokeColor: UIColor
    var lineWidth: CGFloat
    var fillTexture: SKTexture?
    var widthToHeightConstant: CGFloat
    var glowWidth = 0
}
struct Particle2D {
    var particle: SKShapeNode
    private static var particleSkins = [ParticleSkin2D]()
    private var ballRadius: CGFloat
    init(ballRadius: CGFloat) {
        self.ballRadius = ballRadius
        let particleSize = CGSize(width: ballRadius * 0.85, height: ballRadius * 0.85)
        let particleCornerRadius = ballRadius/10.0
        
        self.particle = SKShapeNode(rectOf: particleSize, cornerRadius: particleCornerRadius)
        
        self.particle.glowWidth = 16.0
        self.particle.lineWidth = 2.5
        self.particle.fillColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        self.particle.strokeColor = .blue
        
        self.particle.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.removeFromParent()
        ]))
        
        self.particle.zPosition = -1
//        self.initializeParticleSkins()
        self.setParticlesSkin()
    }
    mutating func setParticlesSkin() {
        if !UserCustomization.buyedParticlesSkinIndexes.isEmpty && UserCustomization.particleSkinIndex < Particle2D.particleSkins.count {
            self.setSkinCode(skinIndex: UserCustomization.particleSkinIndex)
        }
    }
    mutating func setCertainParticleIndex(skinIndex: Int) {
        if skinIndex < Particle2D.particleSkins.count {
            self.setSkinCode(skinIndex: skinIndex)
        }
    }
    private mutating func setSkinCode(skinIndex: Int) {
        let currentPartileSkin = Particle2D.particleSkins[skinIndex]
        
        let particleHeight = self.ballRadius*0.9
        let particleWidth = particleHeight * currentPartileSkin.widthToHeightConstant
        let particleSize = CGSize(width: particleWidth, height: particleHeight)
        self.particle = SKShapeNode(rectOf: particleSize)
        
        self.particle.glowWidth = 16.0
        self.particle.lineWidth = 2.5
        self.particle.fillColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        self.particle.strokeColor = .blue
        
        self.particle.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.removeFromParent()
        ]))
        
        self.particle.zPosition = -1
        
        self.particle.fillColor = currentPartileSkin.fillColor
        self.particle.strokeColor = currentPartileSkin.strokeColor
        self.particle.lineWidth = currentPartileSkin.lineWidth
        
        if let particleTexture = currentPartileSkin.fillTexture {
            self.particle.fillTexture = particleTexture
        }
    }
    func addParticle(to gameNode: SKNode, ball: Ball2D?) {
        if let particle = self.particle.copy() as? SKShapeNode {
            if let ball = ball?.ball {
                // чтобы был небольшой разброс в позиции частиц
                
                let randomPositionX = CGFloat.random(in: -10...10)
                let randomPositionY = CGFloat.random(in: -10...10)
                particle.position = CGPoint(x: ball.position.x + randomPositionX,
                                            y: ball.position.y + randomPositionY)
                
                particle.physicsBody = SKPhysicsBody(rectangleOf: particle.frame.size)
                particle.physicsBody?.affectedByGravity = false
                particle.physicsBody?.angularDamping = 0.0
                particle.physicsBody?.categoryBitMask = 0
                particle.physicsBody?.allowsRotation = true
                particle.physicsBody?.collisionBitMask = 0
                particle.physicsBody?.friction = 0.0
                particle.physicsBody?.linearDamping = 0.0
                
                
                // случайный размер частичек
                let randomScaleFactor = CGFloat.random(in: 0.5...1.4)
                particle.xScale = randomScaleFactor
                particle.yScale = randomScaleFactor

                gameNode.addChild(particle)
                
                let randomVelocityX = CGFloat.random(in: -30...30)
                let randomVelocityY = CGFloat.random(in: -30...30)
                if let v = ball.physicsBody?.velocity {
                particle.physicsBody?.velocity = CGVector(dx: -v.dx*0.2 + randomVelocityX,
                                                          dy: -v.dy*0.2 + randomVelocityY)
                }
                
                let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: 10.0, duration: 1.0))
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                
                particle.run(SKAction.group([
//                    rotate,
                    fadeOut
                ]))
                
                
            }
        }
    }
    
    static func initializeParticleSkins() {
        for i in 0..<(UserCustomization.maxParticleSkinIndex) {
            let textureImage = UIImage(named: "Particle-\(i+1)")
            
            if let textureImage = textureImage {
                let particleWidthToHeightConstant: CGFloat = textureImage.size.width/textureImage.size.height
                let texture = SKTexture(image: textureImage)
                let paddleSkin = ParticleSkin2D(
                      fillColor: .white,
                      strokeColor: .clear,
                      lineWidth: 0,
                      fillTexture: texture,
                      widthToHeightConstant: particleWidthToHeightConstant
                )
                
                self.particleSkins.append(paddleSkin)
            }
        }
        
    }
    
}
