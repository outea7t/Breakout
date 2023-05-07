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
    // битовые маски объектов в игре
    private let paddleBitmask:      Int = 0x1 << 0 // 1
    private let ballBitmask:        Int = 0x1 << 1 // 2
    private let frameBitmask:       Int = 0x1 << 2 // 4
    private let brickBitmask:       Int = 0x1 << 3 // 8
    private let bottomBitMask:      Int = 0x1 << 4 // 16
    private let trajectoryBallMask: Int = 0x1 << 5 // 32
    private let plateBitmask:       Int = 0x1 << 6 // 64
    private let bonusBitMask:       Int = 0x1 << 7 // 128
    
    /// константа, которая используется для нормального уменьшения длины вектора скорости во время изменения размера сцены
    let constantOfBallLengthVelocity: Float = 0.5
    /// константа, на которую умножается скорость мяча, чтобы она оставалась постоянной
    var lengthOfBallVelocityConstant: Float = 0.5
    /// нижняя граница, опустившись ниже которой скорость мяча выравнивается
    var lowerBorderVelocityTrigger: Float = 0.48
    /// верхняя граница, превысив которую скорость мяча выравнивается
    var upperBorderVelocityTrigger: Float = 0.5
    
    let ball: SCNNode
    let ballRadius: Float
    // переменная, которая контролирует скорость мяча
    var ballImpulse = SCNVector3(x: 0.065 * 4, y: 0.0, z: 0.065 * 4)
    
    var isAttachedToPaddle = true
    
    private static var ballSkins = [SCNNode]()
    init(radius: Float) {
        // настройка мяча
        // делаем размер мяча зависимым от размера экрана
        self.ballRadius = radius
        let geometry = SCNSphere(radius: CGFloat(radius))
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.0
        material.metalness.contents = 1.0
        material.diffuse.contents = UIColor.purple
        material.specular.contents = UIColor.red
        geometry.materials = [material]
        
        self.ball = SCNNode(geometry: geometry)
        self.ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry))
        
        self.ball.name = "ball"
        
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
    
    func moveBall(oldPositionOfFrame: SCNVector3, newPositionOfFrame: SCNVector3) {
        let oldBallPosition = ball.presentation.position
        let newBallPositionY = oldBallPosition.y + (newPositionOfFrame.y - oldBallPosition.y)
        self.ball.position = SCNVector3(x: oldBallPosition.x, y: oldBallPosition.y + newBallPositionY, z: oldBallPosition.z)
    }
    // обновляем позицию и скорость мяча
    mutating func update(paddle: Paddle3D, frame: Frame3D) {
        // скорость мяча по оси ординат всегда должна быть равна 0 (иначе есть шанс, что он улетит в небо)
        let x = ball.presentation.position.x.isNaN
        let y = ball.presentation.position.y.isNaN
        let z = ball.presentation.position.z.isNaN
        if x || y || z {
            self.isAttachedToPaddle = true
            self.ball.position = SCNVector3(paddle.paddle.position.x,
                                            self.ballRadius*1.5,
                                            paddle.paddle.position.z - paddle.paddleVolume.z/2.0 - (self.ballRadius)*1.2)
        }
        
        self.ball.physicsBody?.velocity.y = 0.0
        
        
        // если мяч привязан к ракетке, то он должен находиться прямо на ней (высчитываем его позицию)
        if self.isAttachedToPaddle {
            self.ball.physicsBody?.clearAllForces()
            if !x && !y && !z {
                self.ball.position = SCNVector3(paddle.paddle.position.x,
                                                self.ballRadius*1.5,
                                                paddle.paddle.position.z - paddle.paddleVolume.z/2.0 - (self.ballRadius)*1.2)
            }
        } else {
            // поправляем работу sceneKit и если мяч сильно замедляется или сильно ускоряется, то данный алгоритм нормализует скорость мяча
            if let currentBallVelocity = self.ball.physicsBody?.velocity {
                let simdVelocity = simd_float2(Float(currentBallVelocity.x),
                                               Float(currentBallVelocity.z))
                
                let normalizedVelocity = simd_normalize(simdVelocity)
                
                let newBallVelocity = SCNVector3(
                    normalizedVelocity.x * self.lengthOfBallVelocityConstant * 0.9,
                    0.0,
                    normalizedVelocity.y * self.lengthOfBallVelocityConstant * 0.9)
                self.ball.physicsBody?.velocity = newBallVelocity
            }
        }
        guard let physicsBody = self.ball.physicsBody else {
            return
        }
        if physicsBody.velocity.z <= 0.01 && physicsBody.velocity.z != 0 {
            switch physicsBody.velocity.z.sign {
            case .plus:
                self.ball.physicsBody?.velocity.z -= 0.01
            case .minus:
                self.ball.physicsBody?.velocity.z += 0.01
            }
        }
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
    /// перезагружаем мяч (когда, например, переходим к новому уровню)
    mutating func reset() {
        self.isAttachedToPaddle = true
    }
    mutating func updateBallVelocityLength(scaleFactor: Float) {
        self.lengthOfBallVelocityConstant = self.constantOfBallLengthVelocity*scaleFactor
    }
    
    func setBallSkin() {
        if !UserCustomization._3DbuyedBallSkinIndexes.isEmpty && UserCustomization._3DballSkinIndex < Ball3D.ballSkins.count {
            let material = SCNMaterial()
            if let skinToDelete = self.ball.childNode(withName: "Ball", recursively: true) {
                skinToDelete.removeFromParentNode()
            }
            self.ball.geometry?.materials.first?.diffuse.contents = UIColor.clear
//            self.ball.geometry?.materials.first?.diffuse = UIColor.clear
            let choosedSkinIndex = UserCustomization._3DballSkinIndex
            let choosedModel = Ball3D.ballSkins[choosedSkinIndex]
            choosedModel.position = SCNVector3()
            self.ball.addChildNode(choosedModel)
        }
    }
    static func initializeBallSkins() {
        for i in 1...UserCustomization._3DmaxBallSkinIndex {
            guard let scene = SCNScene(named: "Ball-\(i).dae") else {
                return
            }
            guard let model = scene.rootNode.childNode(withName: "Ball", recursively: true) else {
                return
            }
            Ball3D.ballSkins.append(model)
        }
    }
    
}

/*
 // старый алгоритм обновления скорости мяча
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
 */
