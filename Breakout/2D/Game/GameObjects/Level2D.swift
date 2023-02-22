//
//  Level.swift
//  Breakout
//
//  Created by Out East on 28.08.2022.
//

import Foundation
import UIKit
import SpriteKit

struct Level2D {
    var bricks = [Brick2D]()
    let rows: UInt, cols: UInt
    let bricksDescription: [UInt]
    init(rows: UInt, cols: UInt, bricksDescription: [UInt]) {
        self.rows = rows
        self.cols = cols
        self.bricksDescription = bricksDescription
    }
    
    mutating func loadLevel(to gameNode: SKSpriteNode, frame: CGRect) {
        
        // вычисляем размер кирпичика в зависимости от размера сцены
        let size = CGSize(width: frame.width/CGFloat(self.cols),
                      height: frame.height/CGFloat(2*self.rows))
        // настройка кирпичиков
        for row in 0..<self.rows {
            for col in 0..<self.cols {
                let index = Int(row * self.cols + col)
                let health = self.bricksDescription[index]
                let brick = Brick2D(health: health,
                                    isSolid: false,
                                    frame: frame,
                                    rows: self.rows,
                                    cols: self.cols,
                                    row: row
                )
                
                // позиция след. кирпичика = + полторы длины старого (позиция в центре кирпичика)
                if health > 0 {
                brick.add(to: gameNode, in: CGPoint(x: size.width/2.0 + size.width*CGFloat(col),
                                                    y: frame.height - (size.height/2.0 + size.height*CGFloat(row))))
                    self.bricks.append(brick)
                }
            }
        }
    }
    
    func collisionHappened(brickNode: SKNode) {
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
        
        if self.bricks.isEmpty {
            return true
        }
        return false
    }
    
    mutating func removeAllBricksBeforeSettingLevel() {
        for brick in self.bricks {
            brick.brick.removeAllChildren()
            brick.brick.removeFromParent()
        
        }
    }
    mutating func resetLevel(frame: CGRect, gameNode: SKSpriteNode) {
        // сначала удаляем все кирпичики
        self.removeAllBricksBeforeSettingLevel()
        // потом убираем все элементы массива
        self.bricks.removeAll()
        // вычисляем размер кирпичика в зависимости от размера сцены
        let size = CGSize(width: frame.width/CGFloat(self.cols),
                      height: frame.height/CGFloat(2*self.rows))
        // потом заполняем этот массив кирпичиками
        for row in 0..<self.rows {
            for col in 0..<self.cols {
                let index = Int(row * self.cols + col)
                let health = self.bricksDescription[index]
                var brick = Brick2D(health: health,
                                    isSolid: false,
                                    frame: frame,
                                    rows: self.rows,
                                    cols: self.cols,
                                    row: row
                )
                // позиция след. кирпичика = + полторы длины старого (позиция в центре кирпичика)
                if health > 0 {
                    brick.add(to: gameNode, in: CGPoint(x: size.width/2.0 + size.width*CGFloat(col),
                                                    y: frame.height - (size.height/2.0 + size.height*CGFloat(row))))
                    
                    self.bricks.append(brick)
                }
            }
        }
    }
}
