//
//  Ball3D.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 03.09.2022.
//

import Foundation
import SceneKit
import ARKit

struct Ball3D {
    // битовые маски (для логики столкновений)
    private let paddleBitmask:      Int = 0x1 << 0 // 1
    private let ballBitmask:        Int = 0x1 << 1 // 2
    private let frameBitmask:       Int = 0x1 << 2 // 4
    private let brickBitmask:       Int = 0x1 << 3 // 8
    private let bottomBitMask:      Int = 0x1 << 4 // 16
    private let trajectoryBallMask: Int = 0x1 << 5 // 32
    private let plateBitmask:       Int = 0x1 << 6 // 64
    
    let ball: SCNNode
    let ballRadius: Float
    // переменная, которая контролирует скорость мяча
    var ballImpulse = SCNVector3(x: 0.065 * 4, y: 0.0, z: 0.065 * 4)
    
    var isAttachedToPaddle = true
    
    init(radius: Float) {
        // настройка мяча
        // делаем размер мяча зависимым от размера экрана
        self.ballRadius = radius
        let geometry = SCNSphere(radius: CGFloat(radius))
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.3
        material.metalness.contents = 1.0
        material.diffuse.contents = UIColor.purple
        material.specular.contents = UIColor.red
        geometry.materials = [material]
        
        self.ball = SCNNode(geometry: geometry)
        self.ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry))
        
        self.ball.name = "ball3"
        
        // настраиваем физическое тело
        self.ball.physicsBody?.restitution = 1.0
        self.ball.physicsBody?.damping = 0.0
        self.ball.physicsBody?.friction = 0.0
        self.ball.physicsBody?.rollingFriction = 0.0
        self.ball.physicsBody?.isAffectedByGravity = false
        self.ball.physicsBody?.allowsResting = false
        // настраиваем битовые маски
        self.ball.physicsBody?.categoryBitMask = self.ballBitmask
        let collision: Int = self.frameBitmask | self.brickBitmask | self.bottomBitMask | self.paddleBitmask
        
        self.ball.physicsBody?.collisionBitMask = collision
        self.ball.physicsBody?.contactTestBitMask = collision
    }
    
    // обновляем позицию и скорость мяча
    func update(paddle: Paddle3D) {
        // скорость мяча по оси ординат всегда должна быть равна 0 (иначе есть шанс, что он улетит в небо)
        self.ball.physicsBody?.velocity.y = 0.0
        // если мяч привязан к ракетке, то он должен находиться прямо на ней (высчитываем его позицию)
        if self.isAttachedToPaddle {
            self.ball.physicsBody?.clearAllForces()
            self.ball.position = SCNVector3(paddle.paddle.position.x,
                                            self.ball.position.y,
                                            paddle.paddle.position.z - paddle.paddleVolume.z/2.0 - self.ballRadius/2.0)
            
        }
        // иначе обновляем скорость мяча
//        else {
//            if let v = self.ball.physicsBody?.velocity {
//                if (abs(v.x) < self.ballImpulse.x || abs(v.x) > self.ballImpulse.x) && v.x != 0 {
//                    self.ball.physicsBody?.velocity.x = self.ballImpulse.x * (v.x/abs(v.x))
//                } else if (abs(v.z) < self.ballImpulse.z || abs(v.z) > self.ballImpulse.z) && v.z != 0{
//                    self.ball.physicsBody?.velocity.z = self.ballImpulse.z * (v.z/abs(v.z))
//                }
//            }
//        }
    }
    // добавляем к ноде
    func add(to node: SCNNode, in position: SCNVector3) {
        node.addChildNode(self.ball)
        self.ball.position = position
        self.ball.physicsBody?.applyForce(self.ballImpulse, asImpulse: true)
    }
    mutating func removedFromPaddle(with impulse: SCNVector3) {
        self.isAttachedToPaddle = false
        self.ball.physicsBody?.velocity = SCNVector3()
        self.ballImpulse = SCNVector3(abs(impulse.x),
                                      abs(impulse.y),
                                      abs(impulse.z))
        
        self.ball.physicsBody?.applyForce(impulse, asImpulse: true)
    }
    // перезагружаем мяч (когда, например, переходим к новому уровню)
    mutating func reset() {
        self.isAttachedToPaddle = true
    }
    
}
