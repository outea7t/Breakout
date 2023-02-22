//
//  Frame3D.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 03.09.2022.
//

import Foundation
import SceneKit
import ARKit
import UIKit

struct Frame3D {
    // битовые маски (для логики столкновений)
    private let paddleBitmask:      Int = 0x1 << 0 // 1
    private let ballBitmask:        Int = 0x1 << 1 // 2
    private let frameBitmask:       Int = 0x1 << 2 // 4
    private let brickBitmask:       Int = 0x1 << 3 // 8
    private let bottomBitMask:      Int = 0x1 << 4 // 16
    private let trajectoryBallMask: Int = 0x1 << 5 // 32
    private let plateBitmask:       Int = 0x1 << 6 // 64
    
    var plate: SCNNode
    let plateVolume: SCNVector3
    
    var frontWall: SCNNode
    let frontWallVolume: SCNVector3
    
    var leftSideWall: SCNNode
    let leftSideWallVolume: SCNVector3
    
    var bottomWall: SCNNode
    let bottomWallVolume: SCNVector3
    
    var rightSideWall: SCNNode
    let rightSideWallVolume: SCNVector3
    
    init(plateVolume: SCNVector3, frontWallVolume: SCNVector3, leftSideWallVolume: SCNVector3, bottomWallVolume: SCNVector3, rightSideWallVolume: SCNVector3) {
        
        self.plate = SCNNode()
        self.plate.name = "plate"
        self.plateVolume = plateVolume
        
        self.frontWall = SCNNode()
        self.frontWall.name = "frontWall"
        self.frontWallVolume = frontWallVolume
        
        self.leftSideWall = SCNNode()
        self.leftSideWall.name = "leftSideWall"
        self.leftSideWallVolume = leftSideWallVolume
        
        self.bottomWall = SCNNode()
        self.bottomWall.name = "bottomWall"
        self.bottomWallVolume = bottomWallVolume
        
        self.rightSideWall = SCNNode()
        self.rightSideWall.name = "rightSideWall"
        self.rightSideWallVolume = rightSideWallVolume
        
        
        self.plate = initPlate()
        self.frontWall = initWall(volume: frontWallVolume)
        self.leftSideWall = initWall(volume: leftSideWallVolume)
        self.bottomWall = initWall(volume: bottomWallVolume, true)
        self.rightSideWall = initWall(volume: rightSideWallVolume)
    }
    private func initPlate() -> SCNNode {
        let plate = SCNNode()
        plate.name = "plate"
        let plateVolume = self.plateVolume
        plate.geometry = SCNBox(width: CGFloat(plateVolume.x),
                                height: CGFloat(plateVolume.y),
                                length: CGFloat(plateVolume.z),
                                chamferRadius: 0)
        
        // цвет объекта
        // настраиваем материал таким образом, чтобы он чуть-чуть отражал поверхность
        let material = SCNMaterial()
//        material.lightingModel = .physicallyBased
        material.diffuse.contents = #colorLiteral(red: 0.3755680323, green: 0.3933776915, blue: 0.7154480219, alpha: 1)
        // цвет,который объект отражает  (аккуратно - цвет отражения смешивается с цветом объекта)
        material.specular.contents = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
//        material.roughness.contents = 0.5
//        material.metalness.contents = 0.85
        material.emission.contents = UIColor.black
        plate.geometry?.materials = [material]

        if let plateGeometry = plate.geometry {
            let shapeOfPlate = SCNPhysicsShape(geometry: plateGeometry, options: nil)
            plate.physicsBody = SCNPhysicsBody(type: .static, shape: shapeOfPlate)
        }
        

        // настраиваем физическое тело для тарелки
        plate.physicsBody?.restitution = 1.0
        plate.physicsBody?.damping = 0.0
        plate.physicsBody?.friction = 0.0
        plate.physicsBody?.rollingFriction = 0.0
        plate.physicsBody?.isAffectedByGravity = false
        // настраиваем битовые маски
        plate.physicsBody?.categoryBitMask = self.plateBitmask
        plate.physicsBody?.collisionBitMask = self.ballBitmask | self.trajectoryBallMask
        plate.physicsBody?.contactTestBitMask = self.ballBitmask
        return plate
    }
    private func initWall(volume: SCNVector3, _ isBottom: Bool = false) -> SCNNode {
        let wall = SCNNode()
        let wallVolume = volume
        wall.geometry = SCNBox(width: CGFloat(wallVolume.x),
                               height: CGFloat(wallVolume.y),
                               length: CGFloat(wallVolume.z),
                               chamferRadius: 0)
        
        let material = SCNMaterial()
//        material.lightingModel = .physicallyBased
        
        material.diffuse.contents = #colorLiteral(red: 0.5671008229, green: 1, blue: 0.7511768937, alpha: 1)
        material.specular.contents = #colorLiteral(red: 0, green: 0.1004967913, blue: 1, alpha: 1)
//        material.roughness.contents = 0.5
//        material.metalness.contents = 0.85
        material.emission.contents = UIColor.black
        
        wall.geometry?.materials = [material]
        if let geometry = wall.geometry {
            let shapeOfWall = SCNPhysicsShape(geometry: geometry, options: nil)
            wall.physicsBody = SCNPhysicsBody(type: .static, shape: shapeOfWall)
        }
        
        // настраиваем физическое тело
        wall.physicsBody?.restitution = 1.0
        wall.physicsBody?.damping = 0.0
        wall.physicsBody?.friction = 0.0
        wall.physicsBody?.rollingFriction = 0.0
        wall.physicsBody?.isAffectedByGravity = false
        // настраиваем битовые маски
        if isBottom {
            wall.physicsBody?.categoryBitMask = self.bottomBitMask
        } else {
            wall.physicsBody?.categoryBitMask = self.frameBitmask
        }
        wall.physicsBody?.collisionBitMask = self.ballBitmask | self.trajectoryBallMask
        wall.physicsBody?.contactTestBitMask = self.ballBitmask
        
        return wall
    }
    // добавляем рамку в сцену
    func add(to scene: SCNScene, in position: SCNVector3) {
        self.plate.position = position
        scene.rootNode.addChildNode(plate)
        
        self.plate.addChildNode(frontWall)
        self.plate.addChildNode(leftSideWall)
        self.plate.addChildNode(bottomWall)
        self.plate.addChildNode(rightSideWall)
        
        self.frontWall.position = SCNVector3(x: 0,
                                             y: plateVolume.y/2.0 + frontWallVolume.y/2.0,
                                             z: 0 - plateVolume.z/2.0 - frontWallVolume.z/2.0)
        
        self.leftSideWall.position = SCNVector3(x: 0 - plateVolume.x/2.0 - leftSideWallVolume.x/2.0,
                                                y: plateVolume.y/2.0 + leftSideWallVolume.y/2.0,
                                                z:0)
        self.rightSideWall.position = SCNVector3(x: plateVolume.x/2.0 + rightSideWallVolume.x/2.0,
                                                 y: plateVolume.y/2.0 + rightSideWallVolume.y/2.0,
                                                 z: 0)
        self.bottomWall.position = SCNVector3(x: 0,
                                              y: plateVolume.y/2.0 + bottomWallVolume.y/2.0,
                                              z: plateVolume.z/2.0 + bottomWallVolume.z/2.0)
        
    }
}
