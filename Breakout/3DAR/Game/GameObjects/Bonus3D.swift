//
//  Bonus3D.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 03.09.2022.
//

import Foundation
import SceneKit
import ARKit
import UIKit

// тут должен быть код с логикой бонусов когда - то
enum BonusType3D: Int {
    case addLive                 = 0
    case increaseBallSpeed       = 1
    case decreaseSpeedOfPaddle   = 2
    case rotate                  = 3
    case maxValue                = 4
}
struct Bonus3D {
    // битовые маски объектов в игре
    private let paddleBitmask:      Int = 0x1 << 0 // 1
    private let ballBitmask:        Int = 0x1 << 1 // 2
    private let frameBitmask:       Int = 0x1 << 2 // 4
    private let brickBitmask:       Int = 0x1 << 3 // 8
    private let bottomBitMask:      Int = 0x1 << 4 // 16
    private let trajectoryBallMask: Int = 0x1 << 5 // 32
    private let plateBitmask:       Int = 0x1 << 6 // 64
    private let bonusBitMask:       Int = 0x1 << 7 // 128
    /// node бонуса
    var bonus: SCNNode
    /// тип бонуса
    var type: BonusType3D
    /// цвет бонуса
    /// в будущем хочу сделать разные цветовые схемы для уровней
    var color: UIColor

    /// позиция, где бонус появился
    private var position: SCNVector3
    private var bonusActivationSoundSource: SCNAudioSource?
    init(
        frame: Frame3D,
        position: SCNVector3
    ) {
        
        self.position = position
        self.color = .white

        let bonusGeometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.01)
        let bonusMaterial = SCNMaterial()
        bonusMaterial.diffuse.contents = self.color
        bonusMaterial.lightingModel = .physicallyBased
        bonusMaterial.metalness.contents = 1.0
        bonusMaterial.roughness.contents = 0.0
        bonusGeometry.materials = [bonusMaterial]
        
        self.bonus = SCNNode(geometry: bonusGeometry)
        self.bonus.position = position

        let rawBonusType = Int.random(in: 0..<BonusType2D.maxValue.rawValue)
        if let bonusType = BonusType3D(rawValue: rawBonusType) {
            self.type = bonusType
        } else {
            self.type = .addLive
        }
        let ballSpeedBonusScene = SCNScene(named: "Bonus-BallSpeed.dae")!
        let ballSpeedBonusModel = ballSpeedBonusScene.rootNode.childNode(withName: "Bonus", recursively: true)!
        ballSpeedBonusModel.position = SCNVector3()
        ballSpeedBonusModel.transform = SCNMatrix4Scale(ballSpeedBonusModel.transform,
                                                        0.35,
                                                        0.35,
                                                        0.35)
        
        let liveBonusScene = SCNScene(named: "Bonus-Live.dae")!
        let liveBonusModel = liveBonusScene.rootNode.childNode(withName: "Bonus", recursively: true)!
        liveBonusModel.position = SCNVector3()
        liveBonusModel.transform = SCNMatrix4Scale(liveBonusModel.transform,
                                                   0.35,
                                                   0.35,
                                                   0.35)
        
        let paddleSlowedBonusScene = SCNScene(named: "Bonus-PaddleSlowed.dae")!
        let paddleSlowedBonusModel = paddleSlowedBonusScene.rootNode.childNode(withName: "Bonus", recursively: true)!
        paddleSlowedBonusModel.position = SCNVector3()
        paddleSlowedBonusModel.transform = SCNMatrix4Scale(paddleSlowedBonusModel.transform,
                                                           0.35,
                                                           0.35,
                                                           0.35)
        
        let rotateBonusScene = SCNScene(named: "Bonus-Rotate.dae")!
        let rotateBonusModel = rotateBonusScene.rootNode.childNode(withName: "Bonus", recursively: true)!
        rotateBonusModel.position = SCNVector3()
        rotateBonusModel.transform = SCNMatrix4Scale(rotateBonusModel.transform,
                                                     0.35,
                                                     0.35,
                                                     0.35)
        
        switch self.type {
        case .addLive:
            self.bonus.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            self.bonus.addChildNode(liveBonusModel)
        case .increaseBallSpeed:
            self.bonus.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            self.bonus.addChildNode(ballSpeedBonusModel)
        case .decreaseSpeedOfPaddle:
            self.bonus.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            self.bonus.addChildNode(paddleSlowedBonusModel)
        case .rotate:
            self.bonus.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            self.bonus.addChildNode(rotateBonusModel)
        default:
            self.bonus.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        }
        
        let bonusShape = SCNPhysicsShape(geometry: bonusGeometry)
        self.bonus.physicsBody = SCNPhysicsBody(type: .static, shape: bonusShape)
        self.bonus.physicsBody?.isAffectedByGravity = false
        self.bonus.physicsBody?.categoryBitMask = self.bonusBitMask
        self.bonus.physicsBody?.collisionBitMask = self.paddleBitmask | self.bottomBitMask
        self.bonus.physicsBody?.contactTestBitMask = self.paddleBitmask | self.bottomBitMask
        
        self.setBonusActivationSound()
    }
    private mutating func setBonusActivationSound() {
        guard let url = Bundle.main.url(forResource: SoundNames.bonusActivation.rawValue, withExtension: "wav") else {
            return
        }
        guard let audioSource = SCNAudioSource(url: url) else {
            return
        }
        audioSource.isPositional = true
        audioSource.volume = UserSettings.soundsVolumeValue
        audioSource.loops = false
        audioSource.shouldStream = true
        audioSource.load()
        
        self.bonusActivationSoundSource = audioSource
    }
    func playBonusActivationSound() {
        guard let bonusActivationSoundSource = self.bonusActivationSoundSource else {
            return
        }
        bonusActivationSoundSource.volume = UserSettings.soundsVolumeValue
        let playAction = SCNAction.playAudio(bonusActivationSoundSource, waitForCompletion: false)
        self.bonus.runAction(playAction)
    }
    /// с определенным шансом спавним бонус
    /// возвращает true, если бонус появился
    /// false - если нет
    func tryToAdd(to frame: Frame3D) -> Bool {
        if random(border: 5) {
            if self.type != .rotate {
                frame.plate.addChildNode(bonus)
            }
            // скорость бонуса
            let bonusVelocity: Float = 0.1
            // расчитываем время относительно их расстояния до низа экрана, чтобы их скорость была одинаковой
            var timeToBottom: TimeInterval = 0
            // из-за систем координат plate (0;0;0 находится в центре node) мы разделяем три случая
            
                // дальше чем центр
            timeToBottom = TimeInterval((frame.bottomWall.position.z - self.position.z) / bonusVelocity)
            

            let destinationPosition = SCNVector3(x: self.position.x,
                                                 y: self.position.y,
                                                 z: frame.bottomWall.presentation.position.z)
            let moveAction = SCNAction.move(to: destinationPosition, duration: timeToBottom)

            self.bonus.runAction(moveAction)

            return true
        }

        return false
    }
    func remove() {
        let resizeAction = SCNAction.scale(to: 0.0, duration: 0.4)
        let sequence = SCNAction.sequence([
            resizeAction,
            SCNAction.removeFromParentNode()
        ])
        self.bonus.runAction(sequence)
    }
    
    /// задаем шанс, с которым может появиться бонус
    /// сделано для того, чтобы бонусы разных типов могли появляться с разной частотой
    private func random(border: Int) -> Bool {
        let rand = Int.random(in: 0...border)
        return rand == 0
    }

}
