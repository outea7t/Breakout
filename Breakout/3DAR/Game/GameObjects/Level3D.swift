//
//  Level3D.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 03.09.2022.
//

import Foundation
import SceneKit
import ARKit
import UIKit

/// 3Д уровень для раздела игры в дополненной реальности
struct Level3D {
    
    var _3StarTime: TimeInterval?
    var _2StarTime: TimeInterval?
    
    var bricks = [Brick3D]()
    let rows: UInt, cols: UInt
    let bricksDescription: [UInt]
    init(rows: UInt, cols: UInt, bricksDescription: [UInt], _3StarTime: TimeInterval?, _2StarTime: TimeInterval?) {
        
        self._3StarTime = _3StarTime
        self._2StarTime = _2StarTime
        
        self.rows = rows
        self.cols = cols
        self.bricksDescription = bricksDescription
    }

    mutating func loadLevel(to frame: Frame3D) {
        // вычисляем размер кирпичика в зависимости от размера сцены
        let frameVolume = frame.plateVolume
        let brickHeight: Float = 0.05
        let brickVolume = SCNVector3(frameVolume.x/Float(cols),
                                     brickHeight,
                                     frameVolume.z/(2.0*Float(rows)))
        // настройка кирпичиков
        for row in 0..<self.rows {
            for col in 0..<self.cols {
                let index = Int(row * self.cols + col)
                let health = self.bricksDescription[index]
                let brick = Brick3D(volume: brickVolume, color: UIColor.gray, health: Int(health), isSolid: false)

                // позиция след. кирпичика = + полторы длины старого (позиция в центре кирпичика)
                if health > 0 {
                    let brickPosition = SCNVector3(x: -frameVolume.x/2.0 + brickVolume.x/2.0 + brickVolume.x*Float(col),
                                                   y: brickHeight/2.0,
                                                   z: 0.0 - (brickVolume.z/2.0 + brickVolume.z*Float(row)))
                    brick.add(to: frame.plate, in: brickPosition)
                    self.bricks.append(brick)
                }
            }
        }
    }

    func collisionHappened(brickNode: SCNNode) {
        for brick in bricks {
            if brickNode === brick.brick {
                brick.collision()
            }
        }
    }

    mutating func deleteDestroyedBricks() -> Bool {
        // алгоритм удаления элементов
        // в первом цикле мы сначала запоминаем изначальное кол-во элементов, а потом уменьшаем его - ошибка
        // поэтому мы сначала запоминаем индексы элементов на удаление, а потом удаляем их
        var itemsToDelete = [Int]()
        for i in 0..<self.bricks.count {
            if self.bricks[i].isDestroyed {
                if i < self.bricks.count {
                    itemsToDelete.append(i)
                    
                }
            }
        }
        for i in itemsToDelete {
            self.bricks.remove(at: i)
        }

        return self.bricks.isEmpty
    }

    mutating func removeAllBricksBeforeSettingLevel() {
        for brick in self.bricks {
            brick.healthLabel.removeFromParentNode()
            brick.brick.removeFromParentNode()

        }
    }
    mutating func resetLevel(frame: Frame3D) {
        // сначала удаляем все кирпичики
        self.removeAllBricksBeforeSettingLevel()
        // потом убираем все элементы массива
        self.bricks.removeAll()
        // вычисляем размер кирпичика в зависимости от размера сцены
        let frameVolume = frame.plateVolume
        let brickHeight: Float = 0.05
        let brickVolume = SCNVector3(frameVolume.x/Float(cols),
                                     brickHeight,
                                     frameVolume.z/(2.0*Float(rows)))
        // потом заполняем этот массив кирпичиками
        for row in 0..<self.rows {
            for col in 0..<self.cols {
                let index = Int(row * self.cols + col)
                let health = self.bricksDescription[index]
                let brick = Brick3D(volume: brickVolume, color: UIColor.gray, health: Int(health), isSolid: false)

                // позиция след. кирпичика = + полторы длины старого (позиция в центре кирпичика)
                if health > 0 {
                    let brickPosition = SCNVector3(x: -frameVolume.x/2.0 + brickVolume.x/2.0 + brickVolume.x*Float(col),
                                                   y: brickHeight/2.0,
                                                   z: 0.0 - (brickVolume.z/2.0 + brickVolume.z*Float(row)))
                    brick.add(to: frame.plate, in: brickPosition)
                    self.bricks.append(brick)
                }
            }
        }
    }
}
