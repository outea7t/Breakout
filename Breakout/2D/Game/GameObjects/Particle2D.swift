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
    var glowWidth = 0
}
struct Particle2D {
    
    let particle: SKShapeNode
    private var particleSkins = [ParticleSkin2D]()
    init(ballRadius: CGFloat) {
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
        self.initializeParticleSkins()
        self.setParticlesSkin()
    }
    func setParticlesSkin() {
        if !UserCustomization.buyedParticlesSkinIndexes.isEmpty && UserCustomization.particleSkinIndex < self.particleSkins.count {
            let currentPartileSkin = self.particleSkins[UserCustomization.particleSkinIndex]

            self.particle.fillColor = currentPartileSkin.fillColor
            self.particle.strokeColor = currentPartileSkin.strokeColor
            self.particle.lineWidth = currentPartileSkin.lineWidth
            if let particleTexture = currentPartileSkin.fillTexture {
                self.particle.fillTexture = particleTexture
            }
        }
    }
    
    func addParticle(to gameNode: SKSpriteNode, ball: Ball2D?) {
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
    
    private mutating func initializeParticleSkins() {
        // 1
        let _1ImageTexture = UIImage(named: "Particle-1")
        if let _1ImageTexture = _1ImageTexture {
            let _1Texture = SKTexture(image: _1ImageTexture)
            let _1ParticleSkin = ParticleSkin2D(fillColor: .white,
                                                strokeColor: .white,
                                                lineWidth: 0,
                                                fillTexture: _1Texture)
            self.particleSkins.append(_1ParticleSkin)
        }
        
        // 2
        let _2ImageTexture = UIImage(named: "Particle-2")
        if let _2ImageTexture = _2ImageTexture {
            let _2Texture = SKTexture(image: _2ImageTexture)
            let _2ParticleSkin = ParticleSkin2D(fillColor: .white,
                                                strokeColor: .white,
                                                lineWidth: 0,
                                                fillTexture: _2Texture)
            self.particleSkins.append(_2ParticleSkin)
        }
        // 3
        let _3ImageTexture = UIImage(named: "Particle-3")
        if let _3ImageTexture = _3ImageTexture {
            let _3Texture = SKTexture(image: _3ImageTexture)
            let _3ParticleSkin = ParticleSkin2D(fillColor: .white,
                                                strokeColor: .white,
                                                lineWidth: 0,
                                                fillTexture: _3Texture)
            self.particleSkins.append(_3ParticleSkin)
        }
        // 4
        let _4ImageTexture = UIImage(named: "Particle-4")
        if let _4ImageTexture = _4ImageTexture {
            let _4Texture = SKTexture(image: _4ImageTexture)
            let _4ParticleSkin = ParticleSkin2D(fillColor: .white,
                                                strokeColor: .white,
                                                lineWidth: 0,
                                                fillTexture: _4Texture)
            self.particleSkins.append(_4ParticleSkin)
        }
        // 5
        let _5ImageTexture = UIImage(named: "Particle-5")
        if let _5ImageTexture = _5ImageTexture {
            let _5Texture = SKTexture(image: _5ImageTexture)
            let _5ParticleSkin = ParticleSkin2D(fillColor: .white,
                                                strokeColor: .white,
                                                lineWidth: 0,
                                                fillTexture: _5Texture)
            self.particleSkins.append(_5ParticleSkin)
        }
        // 5
        let _6ImageTexture = UIImage(named: "Particle-6")
        if let _6ImageTexture = _6ImageTexture {
            let _6Texture = SKTexture(image: _6ImageTexture)
            let _6ParticleSkin = ParticleSkin2D(fillColor: .white,
                                                strokeColor: .white,
                                                lineWidth: 0,
                                                fillTexture: _6Texture)
            self.particleSkins.append(_6ParticleSkin)
        }
        
    }
    
}
