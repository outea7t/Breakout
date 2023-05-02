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
    
    var particle: SCNNode
    let particlesPerSecond: Double = 1/10.0
//    private let geometry: SCNShape
    
    private static var particleSkins = [SCNNode]()
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
//        let shape = SCNShape(path: path, extrusionDepth: 0.2 * size)
//        shape.chamferRadius = 0.1
//
//        let material = SCNMaterial()
//
//        material.diffuse.contents = #colorLiteral(red: 1, green: 0.9797136188, blue: 0, alpha: 0.9455970613)
//
//        material.lightingModel = .physicallyBased
//        material.roughness.contents = 0.0
//        material.metalness.contents = 1.0
        
//        shape.materials = [material]
        // создаем ноду
        let scene = SCNScene(named: "Particle-1.dae")!
        let donut = scene.rootNode.childNode(withName: "Particle", recursively: true)!
//        let donutNode = modelNode.childNode(withName: "donut", recursively: true)!
        
//        self.particle = SCNNode(geometry: shape)
        self.particle = donut
        
//        self.particle.scale = SCNVector3(0.5, 0.5, 0.5)
        self.particle.name = "Particle"
//        self.geometry = shape
        
        // настраиваем ее и добавляем к сценe
//        let rotationAngle = 3*Double.pi/2
//        self.particle.rotation = SCNVector4(rotationAngle, 0, 0, rotationAngle)
        
        
        let waitAndDelete = SCNAction.sequence([
            SCNAction.wait(duration: 2.0),
            SCNAction.removeFromParentNode()
        ])
        self.particle.runAction(waitAndDelete)
    }
    
    func addParticle(to ball: Ball3D?, frame: Frame3D) {
        let particle = self.particle.clone()
        guard let isAttachedToPaddle = ball?.isAttachedToPaddle else {
            return
        }
        guard let ball = ball?.ball, !isAttachedToPaddle else {
            return
        }
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
        let decreasedScale = SCNVector3(scale.x*0.5, scale.y*0.5, scale.z*0.5)
        particle.scale = decreasedScale

//        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.particle))
//        self.particle.physicsBody = physicsBody
//        self.particle.physicsBody?.isAffectedByGravity = false
//        self.particle.physicsBody?.damping = 0.0
//        self.particle.physicsBody?.friction = 0.0
//        self.particle.physicsBody?.restitution = 1.0
//        self.particle.physicsBody?.angularDamping = 0.0
//        self.particle.physicsBody?.categoryBitMask = 0
        frame.plate.addChildNode(particle)
        
        let fadeOut = SCNAction.fadeOut(duration: 1.0)
        let rotation = SCNAction.rotate(by: .pi,
                                        around: SCNVector3(0.0, 1.0, 0.0),
                                        duration: 2.0)
        
        var moveAction = SCNAction.wait(duration: 2.0)
        if let v = ball.physicsBody?.velocity {
            
            let moveVector = SCNVector3(-v.x*0.1, 0.1, -v.z*0.1)
            moveAction = SCNAction.move(by: moveVector, duration: 2.0)
            
        }
        particle.runAction(SCNAction.group([
            fadeOut,
            rotation,
            moveAction
        ]))
        
    }
    
    mutating func setParticlesSkin() {
        if !UserCustomization._3DbuyedParticlesSkinIndexes.isEmpty && UserCustomization._3DparticleSkinIndex < Particle3D.particleSkins.count {
            if let skinToDelete = self.particle.childNode(withName: "Particle", recursively: true) {
                skinToDelete.removeFromParentNode()
            }
            self.particle.childNode(withName: "Particle", recursively: true)?.removeFromParentNode()
            let choosedSkinIndex = UserCustomization._3DparticleSkinIndex
            let choosedModel = Particle3D.particleSkins[choosedSkinIndex]
            
            self.particle = choosedModel
            self.particle.name = "Particle"
            self.particle.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
            
        }
    }
    
    static func initializeParticleSkins() {
        for i in 1...UserCustomization._3DmaxParticleSkinIndex {
            guard let scene = SCNScene(named: "Particle-\(i).dae") else {
                return
            }
            guard let model = scene.rootNode.childNode(withName: "Particle", recursively: true) else {
                return
            }
            
            Particle3D.particleSkins.append(model)
        }
    }
}
