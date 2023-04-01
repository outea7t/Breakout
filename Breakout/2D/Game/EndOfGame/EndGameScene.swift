//
//  EndGameScene.swift
//  Breakout
//
//  Created by Out East on 31.07.2022.
//

import UIKit
import SpriteKit

class EndGameScene: SKScene {
    var isWin = false
    
    // конфетти и их цвета
    private var confetti: SKSpriteNode?
    private var winColors = [UIColor]()
    private var loseColors = [UIColor]()
    // анимированная информация об итоге игры
    private var gameLoseLabel: AnimatedText?
    private var gameWinLabel: AnimatedText?
    private var colorsForWinLabelAnimation = [UIColor]()
    // 
    private var animatedParticles: AnimatedParticles?
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0)
        
        self.physicsBody?.friction = 0.5
        self.physicsBody?.linearDamping = 0.5
        
        let confettiSize = CGSize(width: self.frame.width*0.03846, height: self.frame.height*0.02962)
        
        self.confetti = SKSpriteNode(color: .white, size: confettiSize)
        
        // настраиваем варианты цветов для победы
        
        let colorsForWin = [#colorLiteral(red: 0.3169264197, green: 0.9787195325, blue: 0.5586557984, alpha: 1), #colorLiteral(red: 1, green: 0.4980392157, blue: 0.2, alpha: 1), #colorLiteral(red: 0.2969256639, green: 0.5910822749, blue: 1, alpha: 1), #colorLiteral(red: 0.236546725, green: 0.9203231931, blue: 0.9252752662, alpha: 1), #colorLiteral(red: 1, green: 0.9136478305, blue: 0.253780663, alpha: 1), #colorLiteral(red: 0.7343662381, green: 0.3822629452, blue: 1, alpha: 1)]
        self.winColors += colorsForWin
        
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
        
        
//        let wait = SKAction.wait(forDuration: 1.0)
//        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
//        self.confetti?.run(SKAction.sequence([
//            wait,
//            fadeOut,
//            SKAction.removeFromParent()
//        ]))
        
        // настраиваем анимированный текст
        let winW = UIImage(named: "WinW.png")!
        let winI = UIImage(named: "WinI.png")!
        let winN = UIImage(named: "WinN.png")!
        let winExMark = UIImage(named: "Win!.png")!
        let imagesForWinLabel = [winW, winI, winN, winExMark]
        
        self.gameWinLabel = AnimatedText(images: imagesForWinLabel, frame: self.frame, color: .white, sizeConstant: 80)
//        AnimatedText(text: "WIN!", color: .init(red: 0, green: 1, blue: 0, alpha: 1), frame: self.frame,shouldAnimateShadows: false, sizeConstant: 130)
        self.gameWinLabel?.calculatePosition(for: self.frame.size, offsetY: 1.9)
        
        let loseL = UIImage(named: "LoseL.png")!
        let loseO = UIImage(named: "LoseO.png")!
        let loseS = UIImage(named: "LoseS.png")!
        let loseE = UIImage(named: "LoseE.png")!
        let loseExMark = UIImage(named: "Lose!.png")!
        let imagesForLoseLabel = [loseL, loseO, loseS, loseE, loseExMark]
        self.gameLoseLabel = AnimatedText(images: imagesForLoseLabel, frame: self.frame, color: .white, sizeConstant: 80)
//        AnimatedText(text: "LOSE!", color: .init(red: 1, green: 0, blue: 0, alpha: 1), frame: self.frame, shouldAnimateShadows: false, sizeConstant: 120)
        
        self.gameLoseLabel?.calculatePosition(for: self.frame.size, offsetY: 2.1)
        
        if let gameWinLabel = gameWinLabel {
            for letter in gameWinLabel.sprites {
                self.addChild(letter)
            }
        }
        if let gameLoseLabel = gameLoseLabel {
            for letter in gameLoseLabel.sprites {
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
    func setAnimatedParticles() {
        let pointSize = self.frame.height/10
        
        self.animatedParticles = AnimatedParticles(text: "BREAKOUT",
                                                   pointSize: pointSize,
                                                   colors: self.isWin ? self.winColors : self.loseColors,
                                                   enable3D: false)
    }
    // настраиваем анимированный текст
    func setText() {
        // для того, чтобы настроить свечение у надписей
        let blurNode = SKEffectNode()
        blurNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 100])
        blurNode.zPosition = -2
        
        if self.isWin {
            if let gameWinLabel = gameWinLabel {
                for letter in gameWinLabel.sprites {
                    letter.color = .white.withAlphaComponent(1.0)
                }
                
                let glowSize = CGSize(width: gameWinLabel.width*1.2, height: gameWinLabel.height*1.2)
                
                let greenGlow = SKSpriteNode(color: #colorLiteral(red: 0.007843137255, green: 1, blue: 0.1254901961, alpha: 0.4), size: glowSize)
                greenGlow.position = gameWinLabel.position
                
                blurNode.addChild(greenGlow)
                self.addChild(blurNode)
            }
            if let gameLoseLabel = gameLoseLabel {
                for letter in gameLoseLabel.sprites {
                    letter.removeFromParent()
                }
            }
        } else {
            if let gameWinLabel = gameWinLabel {
                for letter in gameWinLabel.sprites {
                    letter.removeFromParent()
                }
            }
            if let gameLoseLabel = gameLoseLabel {
                for letter in gameLoseLabel.sprites {
                    letter.color = .white.withAlphaComponent(1.0)
                }
                let glowSize = CGSize(width: gameLoseLabel.width*1.2, height: gameLoseLabel.height*1.2)
                let redGlow = SKSpriteNode(color: #colorLiteral(red: 1, green: 0.2078431373, blue: 0.1568627451, alpha: 0.4), size: glowSize)
                redGlow.position = gameLoseLabel.position
                
                blurNode.addChild(redGlow)
                self.addChild(blurNode)
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
    override func update(_ currentTime: TimeInterval) {
        if self.isWin {
            self.gameWinLabel?.ambientAnimating(colorToChange: .green, currentTime: currentTime)
        } else {
            self.gameLoseLabel?.ambientAnimating(colorToChange: .red, currentTime: currentTime)
        }
        self.animatedParticles?.update(currentTime)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if self.isWin {
                self.touchDownOnLetterWIN(touch)
            } else {
                self.touchDownOnLetterLOSE(touch)
            }
            if touch.location(in: self).y < self.frame.height*0.6 {
                HapticManager.collisionVibrate(with: .soft, 0.75)
                self.animatedParticles?.animate(touch, scene: self)
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
            if touch.location(in: self).y < self.frame.height*0.6 {
                self.animatedParticles?.animate(touch, scene: self)
            }
        }
    }
    
    private func touchDownOnLetterWIN(_ touch: UITouch) {
//        let randIndex = Int(arc4random()) % self.colorsForWinLabelAnimation.count
//        let randomColor = self.colorsForWinLabelAnimation[randIndex]
        self.gameWinLabel?.touchDown(touchPosition: touch.location(in: self), color: .green)
    }
    private func touchProcessOnLetterWIN(_ touch: UITouch) {
        self.gameWinLabel?.touchProcess(touchPosition: touch.location(in: self), color: .green)
    }
    
    private func touchDownOnLetterLOSE(_ touch: UITouch) {
        self.gameLoseLabel?.touchDown(touchPosition: touch.location(in: self), color: .red)
    }
    private func touchProcessOnLetterLOSE(_ touch: UITouch) {
        self.gameLoseLabel?.touchProcess(touchPosition: touch.location(in: self), color: .red)
    }
}
