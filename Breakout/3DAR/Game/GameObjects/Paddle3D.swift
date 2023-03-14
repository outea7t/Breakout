//
//  Paddle3D.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 03.09.2022.
//

import Foundation
import SceneKit
import ARKit
import UIKit


struct Paddle3D {
    // битовые маски различных объектов
    // битовые маски (для логики столкновений)
    private let paddleBitmask:      Int = 0x1 << 0 // 1
    private let ballBitmask:        Int = 0x1 << 1 // 2
    private let frameBitmask:       Int = 0x1 << 2 // 4
    private let brickBitmask:       Int = 0x1 << 3 // 8
    private let bottomBitMask:      Int = 0x1 << 4 // 16
    private let trajectoryBallMask: Int = 0x1 << 5 // 32
    private let plateBitmask:       Int = 0x1 << 6 // 64
    private let bonusBitMask:       Int = 0x1 << 7 // 128
    
    var paddle: SCNNode
    var paddleVolume: SCNVector3
    init(frame: Frame3D) {
        // настройка ракетки
        // мы изменяем размер ракетки в зависимости от размера экрана
        // умножаем на литеральные константы (наверное плохо), но это нормально работает
        
        let volume = SCNVector3(x: frame.bottomWallVolume.x/3.0,
                                y: 0.06,
                                z: frame.leftSideWallVolume.z/12.5)
        self.paddleVolume = volume
        let geometry = SCNBox(width: CGFloat(volume.x),
                              height: CGFloat(volume.y),
                              length: CGFloat(volume.z),
                              chamferRadius: 0.3)
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.0
        material.metalness.contents = 1.0
        material.ambient.contents = UIColor.blue
        material.specular.contents = UIColor.white
        material.diffuse.contents = UIColor.purple
        geometry.materials = [material]
        
        self.paddle = SCNNode(geometry: geometry)
        self.paddle.position = SCNVector3(x: 0, y: volume.y/2.0, z: frame.plateVolume.z/2.0 - volume.z/2.0)
        
        let shape = SCNPhysicsShape(geometry: geometry)
        self.paddle.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        self.paddle.physicsBody?.damping = 0.0
        self.paddle.physicsBody?.friction = 0.0
        self.paddle.physicsBody?.restitution = 1.0
        self.paddle.physicsBody?.angularDamping = 0.0
        self.paddle.physicsBody?.categoryBitMask = self.paddleBitmask
        self.paddle.physicsBody?.collisionBitMask = self.ballBitmask | self.bonusBitMask
        self.paddle.physicsBody?.contactTestBitMask = self.ballBitmask | self.bonusBitMask
        self.paddle.name = "Paddle"
        
        frame.plate.addChildNode(paddle)
    }
    // движение ракетки
    mutating func move(by result: CGPoint) {
        self.paddle.position.x += Float(result.x)
//        let moveVector = SCNVector3(result.x, 0, 0)
//        self.paddle.runAction(SCNAction.move(by: moveVector, duration:0.0))
        
//        self.paddle.physicsBody?.applyForce(SCNVector3(result.x*0.1, 0, 0), asImpulse: true)
        
    }
    // перезагрузка ракетки
    func reset() {
        self.paddle.position.x = 0.0
    }
    // проверяем, чтобы ракетка не выходила за границы экрана
    func update(frame: Frame3D, isBallAttachedToPaddle: Bool) {
        if self.paddle.position.x + self.paddleVolume.x/2.0 > frame.plateVolume.x/2.0 {
            self.paddle.position = SCNVector3(x: frame.plateVolume.x/2.0 - self.paddleVolume.x/2.0,
                                              y: paddleVolume.y/2.0,
                                              z: frame.plateVolume.z/2.0 - paddleVolume.z/2.0)
        } else if self.paddle.position.x - self.paddleVolume.x/2.0 < -frame.plateVolume.x/2.0 {
            self.paddle.position = SCNVector3(x: -frame.plateVolume.x/2.0 + paddleVolume.x/2.0,
                                              y: paddleVolume.y/2.0,
                                              z: frame.plateVolume.z/2.0 - paddleVolume.z/2.0)
        }
        
        if isBallAttachedToPaddle {
            self.paddle.position.x = 0.0
        }
        if paddle.position.y > 0.03 || paddle.position.y < 0.03 {
            paddle.position.y = 0.03
        }
        if paddle.position.z > 0.23 || paddle.position.z < 0.023 {
            paddle.position.z = 0.23
        }
    }
    
    

    /// из-за того, что SceneKit - говно и не обновляет позицию ракетки так, как мне нужно (она двигается рывками)
    /// то я создал функцию, которая каждый кадр немного двигает позицию ракетки, чтобы ракетка не двигалась рывками
    mutating func updateNode() {
        let wigglePositionValue = SCNVector3(
            x: Float.random(in: -0.00001...0.0001),
            y: Float.random(in: -0.00001...0.0001),
            z: Float.random(in: -0.00001...0.0001)
        )
        // каждый кадр прибавляем незначительно малые величины к позиции ракетки, чтобы SceneKit пересчитывал node.presentation.position
        self.paddle.position = SCNVector3(x: self.paddle.position.x + wigglePositionValue.x,
                                          y: self.paddle.position.y + wigglePositionValue.y,
                                          z: self.paddle.position.z + wigglePositionValue.z)
    }
}
