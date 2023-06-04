//
//  TrajectoryLine3D.swift
//  Breakout
//
//  Created by Out East on 09.12.2022.
//

import Foundation
import UIKit
import SceneKit
import ARKit

struct TrajectoryLine3D {
    /// текущее направление траектории
    var currentDirection = SCNVector3()
    /// первый ли раз мы нажали на экран (для отслеживания траектории)
    /// чтобы рисовать траекторию каждый раз при нажатии, программа отслеживает позиции последнего касания и текущего
    /// она рисует траекторию только в том случае, если они значительно отличаются
    /// когда мы первый раз нашимаем на экран, то эти переменные еще не установлены
    var isFirstTouch = true
    /// была ли создана траектория
    var isTrajectoryCreated = false
    private var currentTrajetoryBallImpulse = SCNVector3()

    /// мяч для симуляции траектории
    private var trajectoryBall = SCNNode()
    /// точки, отображающие траекторию, которую проделал мяч
    private var trajectoryPoints = [SCNVector3]()

    // битовые маски объектов в игре
    private let paddleBitmask:      Int = 0x1 << 0 // 1
    private let ballBitmask:        Int = 0x1 << 1 // 2
    private let frameBitmask:       Int = 0x1 << 2 // 4
    private let brickBitmask:       Int = 0x1 << 3 // 8
    private let bottomBitMask:      Int = 0x1 << 4 // 16
    private let trajectoryBallMask: Int = 0x1 << 5 // 32
    private let plateBitmask:       Int = 0x1 << 6 // 64
    private let bonusBitMask:       Int = 0x1 << 7 // 128
    
    private let yPositionOfBall: Float
    /// мы сравниваем координату последнего и текущего касаний,
    /// чтобы определить, нужно ли нам рисовать траекторию
    /// это сделано для того, чтобы линия траектории не исчезала слишком часто
    private var lastTouchPosition = SCNVector3()
    /// последний раз, когда появлялся шарик, определяещий линию траектории (сама траектория состоит из шариков)
    private var lastTime = TimeInterval()
    /// текущее время
    private var currentTime = TimeInterval()
    /// шарики, использующиеся для отрисовки траектории
    private var trajectories = [SCNNode]()
    /// мьютекс, использующийся для того, чтобы к массиву trajectories не было одновременного доступа из нескольких потоков
    private var mutex = pthread_mutex_t()
    init(ball: Ball3D, node: SCNNode) {

        let geometry = SCNSphere(radius: CGFloat(ball.ballRadius))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        geometry.materials = [material]
        
        self.trajectoryBall.geometry = geometry
        let physicsShape = SCNPhysicsShape(geometry: geometry)
        self.trajectoryBall.physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        
        self.trajectoryBall.physicsBody?.isAffectedByGravity = false
        self.trajectoryBall.physicsBody?.friction = 0.0
        self.trajectoryBall.physicsBody?.rollingFriction = 0.0
        self.trajectoryBall.physicsBody?.damping = 0.0
        self.trajectoryBall.physicsBody?.restitution = 1.0

        self.trajectoryBall.physicsBody?.categoryBitMask = self.trajectoryBallMask
        self.trajectoryBall.physicsBody?.collisionBitMask = self.frameBitmask | self.brickBitmask | self.paddleBitmask | self.bottomBitMask
        
        trajectoryBall.position = ball.ball.position
        self.yPositionOfBall = ball.ball.position.y
        node.addChildNode(self.trajectoryBall)
        
        pthread_mutex_init(&self.mutex, nil)
    }

    /// эта функция вызывается в touchesBegan или в touchesMoved
    mutating func touchDown(touchLocation: SCNVector3, scene: SCNScene, ball: Ball3D) {
        var currentPosition = touchLocation
        currentPosition = SCNVector3(currentPosition.x*1000,
                                     currentPosition.y,
                                     currentPosition.z*1000)
        

        // при больших значениях мы просто отправляем мяч сталкиваться с дном - мгновенно проигрывать
        if currentPosition.z < 200 {
            if (abs(lastTouchPosition.x - currentPosition.x) > 5 || abs(lastTouchPosition.z - currentPosition.z) > 5)  {
                self.tappedScreen(touchLocation, ball)
                lastTouchPosition = currentPosition
            }
            
        }
    }
    
    mutating func update(_ isAttachedToBottom: Bool, _ currentTime: TimeInterval, node: SCNNode) {
        self.currentTime = currentTime
        if currentTime - self.lastTime < 0.3 {
            pthread_mutex_lock(&self.mutex)
            self.trajectoryPoints.append(self.trajectoryBall.presentation.position)
            pthread_mutex_unlock(&self.mutex)
            self.drawTrajectory(node: node)
        }
        if !isAttachedToBottom {
            self.clearTrajectories()
        }
        self.updateTrajectoryBall()
        
    }
    mutating func clearTrajectories() {
        pthread_mutex_lock(&self.mutex)
        self.trajectoryPoints = [SCNVector3]()
        for trajectory in trajectories {
            trajectory.removeFromParentNode()
        }
        pthread_mutex_unlock(&self.mutex)
    }
    /// применяем ипульс к мячу для отрисовки траектории (запускаем физическую симуляцию)
    private mutating func prepareForTrajectory(tappedPoint: SCNVector3, ball: Ball3D) {
        self.trajectoryBall.physicsBody?.velocity = SCNVector3()
        self.trajectoryBall.position = ball.ball.position
        
        var location = tappedPoint
        location.y = self.yPositionOfBall
        
        let t_direction = normalize(SIMD3(x: location.x - self.trajectoryBall.position.x,
                                          y: 0.0,
                                          z: location.z - self.trajectoryBall.position.z))
        let direction = SCNVector3(t_direction.x, 0, t_direction.z)
        
        let increasedDirection = SCNVector3(direction.x*1.3,
                                            0.0,
                                            direction.z*1.3)
        let decreasedDirection = SCNVector3(direction.x * 0.4,
                                            0.0,
                                            direction.z * 0.4)


        self.trajectoryBall.physicsBody?.applyForce(increasedDirection, asImpulse: true)
        self.currentTrajetoryBallImpulse = SCNVector3(abs(increasedDirection.x),
                                                      0.0,
                                                      abs(increasedDirection.z))
        
        self.isTrajectoryCreated = true
        self.currentDirection = decreasedDirection
    }
    /// рисуем линию траектории
    private mutating func drawTrajectory(node: SCNNode) {

        for trajectoryPoint in trajectoryPoints {
            
            let sphereGeometry = SCNSphere(radius: 0.0075)
            let sphereMaterial = SCNMaterial()
            sphereMaterial.diffuse.contents = UIColor.red
            sphereGeometry.materials = [sphereMaterial]
            
            let sphere = SCNNode(geometry: sphereGeometry)
            sphere.position = trajectoryPoint
            sphere.name = "TrajectoryLineSphere"
            node.addChildNode(sphere)
            self.trajectories.append(sphere)
        }
        
    }
    
    private mutating func tappedScreen(_ touchLocation: SCNVector3, _ ball: Ball3D) {
        self.clearTrajectories()
        self.prepareForTrajectory(tappedPoint: touchLocation, ball: ball)
        self.lastTime = self.currentTime
    }
    
    private mutating func updateTrajectoryBall() {
        self.trajectoryBall.physicsBody?.velocity.y = 0.0
        if let v = self.trajectoryBall.physicsBody?.velocity {
            if (abs(v.x) < self.currentTrajetoryBallImpulse.x || abs(v.x) > self.currentTrajetoryBallImpulse.x) && v.x != 0 {
                self.trajectoryBall.physicsBody?.velocity.x = self.currentTrajetoryBallImpulse.x * (v.x/abs(v.x))
            } else if (abs(v.z) < self.currentTrajetoryBallImpulse.z || abs(v.z) > self.currentTrajetoryBallImpulse.z) && v.z != 0{
                self.trajectoryBall.physicsBody?.velocity.z = self.currentTrajetoryBallImpulse.z * (v.z/abs(v.z))
            }
        }
    }
}
