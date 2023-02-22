//
//  AnimatedParticles.swift
//  TestOfRiveAbilities
//
//  Created by Out East on 13.11.2022.
//

import Foundation
import UIKit
import SpriteKit

struct AnimatedParticles {
    /// отображаемый текст
    var text = "BREAKOUT"
    /// цвет частички
    var originalColor = #colorLiteral(red: 0, green: 0.2352433503, blue: 1, alpha: 0.8)
    /// цвета во время анимации
    var colorsDuringAnimation = [UIColor]()
    /// шрифты во время анимации
    var fontsDuringAnimation = [UIFont]()
    /// размер шрифта
    private var pointSize: CGFloat = 75
    /// отображение текста
    private var letters = [SKLabelNode]()
    
    /// для контроля количества частичек
    private let gap: Double = 1.0/12.0
    /// время последнего появления частички
    private var lastTime = TimeInterval()
    private var currentTime: Double = 3.0/10.0
    /// индекс частички, которую при текущем нажатии мы должны заспавнить
    private var indexOfLetterShouldSpawn = 0
    /// активируем тени у частичек
    private var enable3D: Bool = false
    
    init(text: String, pointSize: CGFloat, color: UIColor, enable3D: Bool) {
        self.text = text
        self.originalColor = color
        self.pointSize = pointSize
        self.enable3D = enable3D
        self.initialize()
    }
    init(text: String, pointSize: CGFloat, enable3D: Bool) {
        self.text = text
        self.pointSize = pointSize
        self.enable3D = enable3D
        self.initialize()
    }
    
    private mutating func initialize() {
        let color_1 = #colorLiteral(red: 0.9962161183, green: 1, blue: 0, alpha: 0.8)
        let color_2 = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.8)
        let color_3 = #colorLiteral(red: 0, green: 1, blue: 1, alpha: 0.8)
        let color_4 = #colorLiteral(red: 1, green: 0, blue: 1, alpha: 0.8)
        let color_5 = #colorLiteral(red: 0, green: 1, blue: 0.1056410149, alpha: 0.8)
        self.colorsDuringAnimation += [color_1,color_2,color_3, color_4, color_5]
        
        let font_1 = UIFont(name: "Bungee", size: self.pointSize)
//        let font_2 = UIFont(name: "Marker Felt Thin", size: self.pointSize)
//        let font_3 = UIFont(name: "Times New Roman", size: self.pointSize)
//        let font_3 = UIFont(name: "Avenir Next Heavy Italic", size: self.pointSize)
        if let font_1 = font_1 {
            self.fontsDuringAnimation.append(font_1)
//            self.fontsDuringAnimation.append(font_2)
//            self.fontsDuringAnimation.append(font_3)
//            self.fontsDuringAnimation.append(font_4)
        }
        
        
        for letter in text {
            let labelNode = SKLabelNode(text: String(letter))
            labelNode.fontName = "Futura Bold"
            labelNode.fontSize = self.pointSize
            labelNode.color = self.originalColor
            labelNode.colorBlendFactor = 1.0
            
            if self.enable3D {
                if let copyNode = labelNode.copy() as? SKLabelNode {
                    copyNode.name = "copy"
                    copyNode.zPosition = -1
                    copyNode.position = CGPoint(x: labelNode.frame.width/10.0,
                                                y: -labelNode.frame.height/10.0)
                    copyNode.fontName = labelNode.fontName
                    labelNode.addChild(copyNode)
                    
                }
            }
            self.letters.append(labelNode)
            
            labelNode.position = CGPoint(x: 100, y: 100)
            
            // все частички будут постепенно исчезать
            let fadeOutAnimation = SKAction.fadeOut(withDuration: 1.0)
            let removeFromParentAction = SKAction.removeFromParent()
            
            let fadeAndDisappear = SKAction.sequence([
                fadeOutAnimation,
                removeFromParentAction
            ])
            labelNode.run(fadeAndDisappear)
        }
    }
    /// используется для обновления времени в структуре
    /// для контроля количества букв, появляющихся при нажатии
    mutating func update(_ currentTime: TimeInterval) {
        self.currentTime = currentTime
    }
    /// анимирует частичку при нажатии на экран
    mutating func animate(_ touch: UITouch, scene: SKScene) {
        
            // генерируем частички с небольшим разрывом (чтобы они не сливались)
            if self.currentTime - self.lastTime >= self.gap {
                // если мы слишком долго не активировали эту анимацию, то начинаем анимировать слово с его начала
                if self.currentTime - self.lastTime >= 2.0 {
                    self.indexOfLetterShouldSpawn = 0
                }
                self.lastTime = currentTime
                
                // генерируем буквы в слове последовательно
                let index = self.indexOfLetterShouldSpawn
                self.indexOfLetterShouldSpawn+=1
                // следим, чтобы индекс буквы не был больше количества элементов массива
                if self.indexOfLetterShouldSpawn >= self.letters.count {
                    self.indexOfLetterShouldSpawn = 0
                }
                
                if let nodeShouldSpawn = self.letters[index].copy() as? SKLabelNode {
                    
                    nodeShouldSpawn.position = CGPoint(x: touch.location(in: scene).x ,
                                                       y: touch.location(in: scene).y )
                    
                    // чуть вращаем частичку
                    nodeShouldSpawn.zRotation = Double.pi/2
                    let rotateAction_1 = SKAction.rotate(toAngle: -Double.pi/6, duration: 0.15)
                    let rotateAction_2 = SKAction.rotate(toAngle: 0, duration: 0.2)
                    let rotate = SKAction.sequence([
                        rotateAction_1,
                        rotateAction_2
                    ])
                    nodeShouldSpawn.run(rotate)
                    
                    // случайный цвет и шрифт
                    let color = self.colorsDuringAnimation[self.randomNumber( self.colorsDuringAnimation.count)]
                    let font = self.fontsDuringAnimation[self.randomNumber(self.fontsDuringAnimation.count)]
                    
                    nodeShouldSpawn.fontName = font.fontName
                    nodeShouldSpawn.fontSize = font.pointSize
                    
                    
                    if self.enable3D {
                        if let shadow = nodeShouldSpawn.childNode(withName: "copy") as? SKLabelNode {
                            shadow.fontName = font.fontName
                            shadow.fontSize = font.pointSize
                            
                            let ciColor = CIColor(color: color)
                            let shadowColor = UIColor(red: ciColor.red/2,
                                                      green: ciColor.green/2,
                                                      blue: ciColor.blue/2,
                                                      alpha: ciColor.alpha)
                            shadow.color = shadowColor
                            
                        }
                    }
                    self.resizeAndColorize(colorToChange: color, letter: nodeShouldSpawn)
                    scene.addChild(nodeShouldSpawn)
                }
                
            }
        
    }
    
    /// случайное число для выбора шрифта и цвета буквы
    private func randomNumber(_ upperBorder: Int) -> Int {
        return Int(arc4random()) % upperBorder
    }
    /// функция, анимирующая букву
    private func resizeAndColorize(colorToChange: UIColor, letter: SKLabelNode) {
        let downSize_0 = SKAction.group([
            SKAction.scaleX(to: 1.4, duration: 0.22),
            SKAction.scaleY(to: 0.7, duration: 0.22)
        ])
        
        
        let upSize_0 = SKAction.group([
            SKAction.scaleX(to: 0.7, duration: 0.13),
            SKAction.scaleY(to: 1.35, duration: 0.13)
        ])
        
        
        let downSize_1 = SKAction.group([
            SKAction.scaleX(to: 1.15, duration: 0.12),
            SKAction.scaleY(to: 0.85, duration: 0.12)
        ])
                                         
        let upSize_1 = SKAction.group([
            SKAction.scaleX(to: 0.9, duration: 0.12),
            SKAction.scaleY(to: 1.1, duration: 0.12)
        ])
        
        let normalSize = SKAction.group([
            SKAction.scaleX(to: 1, duration: 0.1),
            SKAction.scaleY(to: 1, duration: 0.1)
        ])
        
        let resizeSequence = SKAction.sequence([
            downSize_0,
            upSize_0,
            downSize_1,
            upSize_1,
            normalSize
        ])
        
        
        let toUserColor = SKAction.colorize(
            with: colorToChange,
            colorBlendFactor: 1.0,
            duration: 0.20)
        let wait = SKAction.wait(forDuration: 0.35)
        
        
        let toOriginalColor = SKAction.colorize(
            with: self.originalColor,
            colorBlendFactor: 1.0,
            duration: 0.15)
        
        let colorizeSequence = SKAction.sequence([
            toUserColor,
            wait,
            toOriginalColor
        ])
        
        let resultAction = SKAction.group([
            resizeSequence,
            colorizeSequence
        ])
        letter.run(SKAction.group([
            resultAction
        ]))
        
    }
}
