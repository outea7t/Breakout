//
//  AREndGameScene.swift
//  Breakout
//
//  Created by Out East on 26.02.2023.
//

import Foundation
import UIKit
import SpriteKit

class AREndGameScene: SKScene {
    var isWin = false
    // конфетти и их цвета
    private var confetti: SKSpriteNode?
    private var winColors = [UIColor]()
    private var loseColors = [UIColor]()
    // анимированная информация об итоге игры
    private var gameLoseLabel: AnimatedText?
    private var gameWinLabel: AnimatedText?
    private var colorsForWinLabelAnimation = [UIColor]()
    
    override func didMove(to view: SKView) {
//        self.view?.backgroundColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.backgroundColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.5)
        
        let confettiSize = CGSize(width: self.frame.width*0.03846, height: self.frame.height*0.02962)
        
        self.confetti = SKSpriteNode(color: .white, size: confettiSize)
        
        // настраиваем варианты цветов для победы
        self.winColors.append(.blue)
        self.winColors.append(.green)
        self.winColors.append(.red)
        self.winColors.append(.purple)
        self.winColors.append(.init(red: 200/255, green: 112/255, blue: 159/255, alpha: 1.0))
        
        // настраиваем варианты для поражения
        self.loseColors.append(.red)
        self.loseColors.append(.init(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0))
        self.loseColors.append(.init(red: 0.2398, green: 0.0, blue: 0.0, alpha: 1.0))
        self.loseColors.append(.init(red: 0.2398, green: 0.1175, blue: 0.0, alpha: 1.0))
        self.loseColors.append(.init(red: 0.2398, green: 0.1175, blue: 0.0, alpha: 1.0))
        
        // настраиваем физическое тело confetti
        self.confetti?.physicsBody = SKPhysicsBody(rectangleOf: confettiSize)
        self.confetti?.physicsBody?.friction = 0.0
        self.confetti?.physicsBody?.linearDamping = 0.0
        self.confetti?.physicsBody?.allowsRotation = true
        
        self.confetti?.zPosition = -1
        
        
        colorsForWinLabelAnimation += [
            .init(red: 0.966, green: 0.0, blue: 0.036, alpha: 1.0),
            .init(red: 0.966, green: 0.904, blue: 0.0, alpha: 1.0),
            .init(red: 0.0, green: 0.964, blue: 0.966, alpha: 1.0),
            .init(red: 0.334, green: 0.0, blue: 0.916, alpha: 1.0)
        ]
        
        
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        
        self.confetti?.run(SKAction.sequence([
            wait,
            fadeOut,
            SKAction.removeFromParent()
        ]))
        
        // настраиваем анимированный текст
        self.gameWinLabel = AnimatedText(text: "WIN!",
                                         color: .init(red: 0, green: 1, blue: 0, alpha: 1),
                                         frame: self.frame,shouldAnimateShadows: true,
                                         sizeConstant: 130,
                                         shadowColor: #colorLiteral(red: 0, green: 0.2982867956, blue: 0, alpha: 1))
        
        self.gameWinLabel?.calculatePosition(for: self.frame.size, offsetY: 2.1)
        
        self.gameLoseLabel = AnimatedText(text: "LOSE!",
                                          color: .init(red: 1, green: 0, blue: 0, alpha: 1),
                                          frame: self.frame, shouldAnimateShadows: true,
                                          sizeConstant: 120,
                                          shadowColor:  #colorLiteral(red: 0.3660959005, green: 0, blue: 0, alpha: 1))
        self.gameLoseLabel?.calculatePosition(for: self.frame.size, offsetY: 2.5)
        
        if let gameWinLabel = gameWinLabel {
            for letter in gameWinLabel.label {
                self.addChild(letter)
            }
        }
        if let gameLoseLabel = gameLoseLabel {
            for letter in gameLoseLabel.label {
                self.addChild(letter)
            }
        }
    }

    // добавляем конфетти
    func addConfetti() {
        for _ in 0..<35 {
            self.createConfetti()
        }
    }
    // настраиваем анимированный текст
    func setText() {
        if self.isWin {
            if let gameWinLabel = gameWinLabel?.label {
                for letter in gameWinLabel {
                    letter.color = .init(red: 0, green: 1, blue: 0, alpha: 1)
                }
            }
            if let gameLoseLabel = gameLoseLabel?.label {
                for letter in gameLoseLabel {
                    letter.color = .init(red: 0, green: 0, blue: 0, alpha: 0)
                    letter.removeFromParent()
                }
            }
        } else {
            if let gameWinLabel = gameWinLabel?.label {
                for letter in gameWinLabel {
                    letter.color = .init(red: 0, green: 0, blue: 0, alpha: 0)
                    letter.removeFromParent()
                }
            }
            if let gameLoseLabel = gameLoseLabel?.label {
                for letter in gameLoseLabel {
                    letter.color = .init(red: 1, green: 0, blue: 0, alpha: 1)
                }
            }
        }
    }
    // функция с настройкой 1 штуки конфетти
    private func createConfetti() {
        if let confetti = self.confetti?.copy() as? SKSpriteNode {
            self.addChild(confetti)
            // мы случайно выбираем 1 цвет из массива
            if self.isWin {
                let randColor = self.winColors[Int(arc4random()) % self.winColors.count]
                confetti.color = randColor
                confetti.colorBlendFactor = 1.0
            } else {
                let randColor = self.loseColors[Int(arc4random()) % self.loseColors.count]
                confetti.color = randColor
                confetti.colorBlendFactor = 1.0
            }
            // "взрыв" с ними будет происходить из центра
            confetti.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            
            // вычисляем случайную скорость (по "у" больше разнообразия)
            let randVelocityX: CGFloat = (CGFloat(arc4random() % 15) - 7.5) * 5.0
            let randVelocityY: CGFloat = (CGFloat(arc4random() % 90) - 45.0) * 2.0
            if self.frame.width > 700 && self.frame.height > 1000 {
                let v = CGVector(dx: randVelocityX * 3.5, dy: randVelocityY * 3.5)
                confetti.physicsBody?.applyImpulse(v)
            } else {
                let v = CGVector(dx: randVelocityX, dy: randVelocityY)
                confetti.physicsBody?.applyImpulse(v)
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if self.isWin {
                self.touchDownOnLetterWIN(touch)
            } else {
                self.touchDownOnLetterLOSE(touch)
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if self.isWin {
                self.touchProcessOnLetterWIN(touch)
            } else {
                self.touchProcessOnLetterLOSE(touch)
            }
        }
    }
    
    private func touchDownOnLetterWIN(_ touch: UITouch) {
        if let gameWinLabel = gameWinLabel?.label {
            for letter in gameWinLabel {
                if letter.contains(touch.location(in: self)) {
                    let randIndex = Int(arc4random()) % self.colorsForWinLabelAnimation.count
                    let randomColor = self.colorsForWinLabelAnimation[randIndex]
                    self.gameWinLabel?.animate(colorToChange: randomColor, letter: letter)
                }
            }
        }
    }
    private func touchProcessOnLetterWIN(_ touch: UITouch) {
        if let gameWinLabel = self.gameWinLabel?.label {
            for (index, letter) in gameWinLabel.enumerated() {
                if letter.contains(touch.location(in: self)) {
                    let color = self.colorsForWinLabelAnimation[index]
                    if !letter.hasActions() {
                        self.gameWinLabel?.animate(colorToChange: color, letter: letter)
                    }
                }
            }
        }
    }
    
    private func touchDownOnLetterLOSE(_ touch: UITouch) {
        if let gameLoseLabel = gameLoseLabel?.label {
            for letter in gameLoseLabel {
                if letter.contains(touch.location(in: self)) {
                    self.gameLoseLabel?.animate(colorToChange: .red, letter: letter)
                }
            }
        }
    }
    private func touchProcessOnLetterLOSE(_ touch: UITouch) {
        if let gameLoseLabel = gameLoseLabel?.label {
            for letter in gameLoseLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.gameLoseLabel?.animate(colorToChange: .red, letter: letter)
                    }
                }
            }
        }
    }
}
