//
//  Brick.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 11.10.2022.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class Brick3D {
    // битовые маски объектов в игре
    private let paddleBitmask:      Int = 0x1 << 0 // 1
    private let ballBitmask:        Int = 0x1 << 1 // 2
    private let frameBitmask:       Int = 0x1 << 2 // 4
    private let brickBitmask:       Int = 0x1 << 3 // 8
    private let bottomBitMask:      Int = 0x1 << 4 // 16
    private let trajectoryBallMask: Int = 0x1 << 5 // 32
    private let plateBitmask:       Int = 0x1 << 6 // 64
    private let bonusBitMask:       Int = 0x1 << 7 // 128
    
    // node кирпичика
    let brick: SCNNode
    // node для отображения здоровья кирпичика
    let healthLabel: SCNNode
    
    // переменные с логикой кирпичика
    // логика здоровья
    var health: Int {
        willSet {
            if let healthInfo = self.healthLabel.geometry as? SCNText {
                healthInfo.string = "\(newValue)"
            }
        }
    }
    var isDestroyed: Bool
    private let isSolid: Bool
    private let brickVolume: SCNVector3
    
    init(volume: SCNVector3, color: UIColor, health: Int, isSolid: Bool) {
        // форма
        
        self.brickVolume = volume
        
        let brickGeometry = SCNBox(width: CGFloat(volume.x),
                                   height: CGFloat(volume.y),
                                   length: CGFloat(volume.z),
                                   chamferRadius: 0.01)       // закругление
        // косметика
        let brickMaterial = SCNMaterial()
        brickMaterial.diffuse.contents = UIColor.gray
        brickMaterial.lightingModel = .physicallyBased
        brickMaterial.roughness.contents = 0.0
        brickMaterial.metalness.contents = 1.0
        brickGeometry.materials = [brickMaterial]
        // настраиваем физику
        self.brick = SCNNode(geometry: brickGeometry)
        self.brick.name = "brick"
        let brickShape = SCNPhysicsShape(geometry: brickGeometry)
        self.brick.physicsBody = SCNPhysicsBody(type: .kinematic, shape: brickShape)
        // настраиваем физическое тело
        self.brick.physicsBody?.restitution = 1.0
        self.brick.physicsBody?.damping = 0.0
        self.brick.physicsBody?.friction = 0.0
        self.brick.physicsBody?.rollingFriction = 0.0
        self.brick.physicsBody?.isAffectedByGravity = false
        self.brick.physicsBody?.allowsResting = false
        // настраиваем битовые маски
        self.brick.physicsBody?.categoryBitMask = self.brickBitmask
        self.brick.physicsBody?.collisionBitMask = self.ballBitmask | self.trajectoryBallMask
        self.brick.physicsBody?.contactTestBitMask = self.ballBitmask
        
        // форма текста
        let textGeometry = SCNText(string: "\(health)", extrusionDepth: 0.25) // толщина текста
        // косметика
        let textMaterial = SCNMaterial()
        textMaterial.lightingModel = .physicallyBased
        textMaterial.roughness.contents = 0.0
        textMaterial.metalness.contents = 1.0
        textMaterial.diffuse.contents = UIColor.cyan
        textGeometry.materials = [textMaterial]
        // шрифт
        textGeometry.font = UIFont.init(name: "Arial Rounded MT Bold", size: 1)
        // присваиваем члену объект текста
        self.healthLabel = SCNNode(geometry: textGeometry)
        
        self.health = health
        if health > 0 {
            self.isDestroyed = false
        } else {
            self.isDestroyed = true
        }
        self.isSolid = isSolid
        
    }
    
    
    func add(to scene: SCNNode, in position: SCNVector3) {
        // тело кирпичика
        self.brick.position = position
        if self.health > 0 {
            scene.addChildNode(self.brick)
        }
        // информация о здоровье
        if !isSolid {
            self.brick.addChildNode(self.healthLabel)
            // настраиваем правильное расположение текста и позицию
            let textSize = SCNVector3(x: self.brickVolume.x*0.35, y: self.brickVolume.y*0.35, z: self.brickVolume.z*0.35)
            let textPosition = SCNVector3(x: -textSize.x/4.0, y: self.brickVolume.y/2.0, z: textSize.z/1.5)
            self.healthLabel.position = textPosition
            self.healthLabel.scale = textSize
            self.healthLabel.rotation = SCNVector4(-Double.pi/2, 0, 0, Double.pi/2)
        }

        
    }
    
    // столкновение с мячом
    func collision() {
        // если здоровье больше 1 то уменьшаем его, иначе уничтожаем кирпичик
        self.health -= 1
        if health <= 0 {
            self.isDestroyed = true
            // сначала убираем текст с кирпичика
            self.healthLabel.removeFromParentNode()
            
            // потом запускаем анимацию уничтожения кирпичика, по окончанию которой мы удаляем его
            self.brick.runAction(SCNAction.group([
                SCNAction.scale(by: 0, duration: 0.4),
                SCNAction.sequence([
                    SCNAction.fadeOut(duration: 0.4),
                    SCNAction.removeFromParentNode()
                ])
            
            ]))
            
        }
    }
    
}
