//
//  Particle3D.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 20.10.2022.
//

import Foundation
import SceneKit
import ARKit
import UIKit


struct Particle3D {
    
    let particle: SCNNode
    private let geometry: SCNShape
    init(ballRadius: Float) {
        let size = Double(ballRadius) * 3.5
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.1 * size, y: 0.5 * size))       // A
        path.addLine(to: CGPoint(x: 0.1 * size, y: 0.1 * size))    // B
        path.addLine(to: CGPoint(x: 0.3 * size, y: 0.1 * size))    // C
        path.addLine(to: CGPoint(x: -0.1 * size, y: -0.5 * size))  // D
        path.addLine(to: CGPoint(x: -0.1 * size, y: -0.1 * size))  // E
        path.addLine(to: CGPoint(x: -0.3 * size, y: 0.1 * size))   // F
        path.close()
        
        // создаем геометрию для ноды (SCNShape)
        let shape = SCNShape(path: path, extrusionDepth: 0.2 * size)
        shape.chamferRadius = 0.1
        
        let material = SCNMaterial()
        
        material.diffuse.contents = #colorLiteral(red: 1, green: 0.9797136188, blue: 0, alpha: 0.9455970613)
        
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.0
        material.metalness.contents = 1.0
        
        shape.materials = [material]
        // создаем ноду
        self.particle = SCNNode(geometry: shape)
        self.particle.name = "Particle"
        self.geometry = shape
        
        // настраиваем ее и добавляем к сцене
//        self.particle.position = SCNVector3(0.0, -0.1, -0.1)
        let rotationAngle = -Double.pi/2
        self.particle.rotation = SCNVector4(rotationAngle, 0, 0, rotationAngle)
        
        
        let waitAndDelete = SCNAction.sequence([
            SCNAction.wait(duration: 2.0),
            SCNAction.removeFromParentNode()
        ])
        self.particle.runAction(waitAndDelete)
        
    }
    
    func addParticle(to ball: Ball3D?, frame: Frame3D) {
        if let particle = self.particle.copy() as? SCNNode {
            let isAttachedToPaddle = ball?.isAttachedToPaddle ?? false
            if let ball = ball?.ball, !isAttachedToPaddle {
                // чтобы был небольшой разброс в позиции частиц
                var randomPosition = Float(Int(arc4random()) % 40 - 20) / 1000.0
                if randomPosition == 0 {
                    randomPosition += 0.001
                }
                particle.position = SCNVector3(ball.presentation.position.x + randomPosition,
                                               ball.presentation.position.y,
                                               ball.presentation.position.z + randomPosition/10.0)
                
                // размер частичек будет так же разный
                let randomSize = Float(1 + Int(arc4random()) % 500) / 1000.0
                let scale = SCNVector3(0.7-randomSize, 0.7-randomSize, 0.7-randomSize)
                particle.scale = scale
                
                let physicsShape = SCNPhysicsShape(geometry: self.geometry)
                let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
                
                self.particle.physicsBody = physicsBody
                self.particle.physicsBody?.isAffectedByGravity = false
                self.particle.physicsBody?.damping = 0.0
                self.particle.physicsBody?.friction = 0.0
                self.particle.physicsBody?.restitution = 1.0
                self.particle.physicsBody?.angularDamping = 0.0
                self.particle.physicsBody?.categoryBitMask = 0
                frame.plate.addChildNode(particle)
                
                let fadeOut = SCNAction.fadeOut(duration: 1.0)
                particle.runAction(SCNAction.group([
                    fadeOut
                ]))
                if let v = ball.physicsBody?.velocity {
                    let force = SCNVector3(-v.x*0.05, 0.035, -v.z*0.05)
                    particle.physicsBody?.applyForce(force,
                                                     asImpulse: true)
                    particle.physicsBody?.applyTorque(SCNVector4(0.0, 0.09, 0.0, 1.0), asImpulse: true)
                }
                
                
            }
        }
    }
}
