//
//  TrajectoryLine2D.swift
//  TestGame
//
//  Created by Out East on 08.12.2022.
//

import Foundation
import SpriteKit
import UIKit


struct TrajectoryLine2D {
    // текущее направление траектории
    var currentDirection = CGVector()
    // была ли создана траектория
    var isTrajectoryCreated = false
    // мяч для симуляции траектории
    private var trajectoryBall = SKShapeNode()
    // точки, отображающие траекторию, которую проделал мяч
    private var trajectoryPoints = [CGPoint]()
    
    // битовые маски различных объектов
    private let ballMask: UInt32           = 0b1 << 0 // 1
    private let paddleMask: UInt32         = 0b1 << 1 // 2
    private let brickMask: UInt32          = 0b1 << 2 // 4
    private let bottomMask: UInt32         = 0b1 << 3 // 8
    private let trajectoryBallMask: UInt32 = 0b1 << 4 // 16
    private let frameMask: UInt32          = 0b1 << 5 // 32
    
    // координаты последнего касания (для дого, чтобы траектория не исчезала постоянно)
    private var lastTouchPosition = CGPoint()
    private var lastTime = TimeInterval()
    private var currentTime = TimeInterval()
    private var trajectories = [SKShapeNode]()
    
    init(ball: Ball2D, scene: SKScene) {
        
        self.trajectoryBall = SKShapeNode(circleOfRadius: ball.ballRadius)
        self.trajectoryBall.physicsBody = SKPhysicsBody(circleOfRadius: ball.ballRadius)
        self.trajectoryBall.physicsBody?.affectedByGravity = false
        self.trajectoryBall.physicsBody?.friction = 0.0
        self.trajectoryBall.physicsBody?.linearDamping = 0.0
        self.trajectoryBall.physicsBody?.restitution = 1.0
        
        self.trajectoryBall.physicsBody?.categoryBitMask = self.trajectoryBallMask
        self.trajectoryBall.physicsBody?.collisionBitMask = self.brickMask | self.frameMask
        scene.addChild(self.trajectoryBall)
        self.trajectoryBall.fillColor = .clear
        self.trajectoryBall.strokeColor = .clear
    }
    
    mutating func touchDown(touch: UITouch, scene: SKScene, ball: Ball2D) {
        let currentPosition = touch.location(in: scene)
        if abs(lastTouchPosition.x - currentPosition.x) > 5 || abs(lastTouchPosition.y - currentPosition.y) > 5 {
            self.tappedScreen(touch.location(in: scene), ball)
            lastTouchPosition = currentPosition
        }
    }
    func touchUp(touch: UITouch) {
        
    }
    mutating func update(_ isAttachedToBottom: Bool, _ currentTime: TimeInterval, scene: SKScene) {
        self.currentTime = currentTime
        if currentTime - self.lastTime < 0.25 {
            self.trajectoryPoints.append(self.trajectoryBall.position)
            self.calculateTrajectory(scene: scene)
        }
        if !isAttachedToBottom {
            self.clearTrajectories()
        }
    }
    mutating func prepareForTrajectory(tappedPoint: CGPoint, ball: Ball2D) {
        self.trajectoryBall.physicsBody?.velocity = CGVector()
        self.trajectoryBall.position = ball.ball.position
        let t_direction = normalize(SIMD2(x: tappedPoint.x - self.trajectoryBall.position.x,
                                y: tappedPoint.y - self.trajectoryBall.position.y))
        var direction = CGVector(dx: t_direction.x, dy: t_direction.y)
        direction = CGVector(dx: direction.dx, dy: direction.dy)
        let increasedDirection = CGVector(dx: direction.dx * 175,
                                          dy: direction.dy * 175)
        
        
        self.trajectoryBall.physicsBody?.applyImpulse(increasedDirection)
        self.isTrajectoryCreated = true
        self.currentDirection = direction
    }
    mutating func calculateTrajectory(scene: SKScene) {
        
        // линия
        let path = SKShapeNode(points: &self.trajectoryPoints, count: self.trajectoryPoints.count)
        // делаем ее штриховой
        let dashed = path.path?.copy(dashingWithPhase: 1, lengths: [15.0,10.0])
        // если у нас получилось заштриховать линию, то рисуем ее
        if let dashed = dashed {
            let pathe = SKShapeNode(path: dashed)
            
            pathe.lineWidth = 6.0
            pathe.strokeColor = .red
            pathe.fillColor = .clear
            pathe.zPosition = 10
            
            scene.addChild(pathe)
            self.trajectories.append(pathe)
            
        }
    }
    mutating func clearTrajectories() {
        self.trajectoryPoints = [CGPoint]()
        for trajectory in trajectories {
            trajectory.removeFromParent()
        }
    }
    private mutating func tappedScreen(_ touchLocation: CGPoint, _ ball: Ball2D) {
        self.clearTrajectories()
        self.prepareForTrajectory(tappedPoint: touchLocation, ball: ball)
        self.lastTime = self.currentTime
        
    }
}
