//
//  MenuScene.swift
//  MyFirstIOSProj
//
//  Created by Out East on 22.07.2022.
//

import SpriteKit
import CoreAudioTypes


class MenuScene: SKScene {
    
    private let particle = SKShapeNode(circleOfRadius: 2.0)
    private var lastTime = TimeInterval(0)
    private var particlePerSecond = CGFloat()
    // анимированное название игры
    private var breakAnimatedLabel: AnimatedText?
    private var outAnimatedLabel: AnimatedText?
    
//    #colorLiteral(red: 0, green: 0.941948235, blue: 0.4499601722, alpha: 1)
    private let colorOfLabelWhileAnimated = #colorLiteral(red: 0.4820304513, green: 0, blue: 0.8957515955, alpha: 1)
//    private let colorOfLabelWhileAnimated = #colorLiteral(red: 0.8019102812, green: 0, blue: 1, alpha: 1)
    private let originalColorOfLabel = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        
        self.physicsWorld.gravity = CGVector()
        
        // настраиваем частички на заднем фоне
        self.particle.strokeColor = .white
        self.particle.fillColor = .white
        
        // настраиваем количество частичек в зависимости от размера устройства
        if self.frame.height > 1000 && self.frame.width > 700 {
            self.particlePerSecond = 1.0/80.0
        } else {
            self.particlePerSecond = 1.0/20.0
        }
        
        let b = UIImage(named: "B.png")!
        let r = UIImage(named: "R.png")!
        let e = UIImage(named: "E.png")!
        let a = UIImage(named: "A.png")!
        let k = UIImage(named: "K.png")!
        let o = UIImage(named: "O.png")!
        let u = UIImage(named: "U.png")!
        let t = UIImage(named: "T.png")!
        
        let images_1 = [b,r,e,a,k]
        // настраиваем интерактивную надпись-название игры
        self.breakAnimatedLabel = AnimatedText(images: images_1, frame: self.frame, color: self.originalColorOfLabel, sizeConstant: 59)

        
        self.breakAnimatedLabel?.calculatePosition(for: self.frame.size, offsetY: 2.25)
        
        let images_2 = [o,u,t]
        self.outAnimatedLabel = AnimatedText(images: images_2, frame: self.frame, color: self.originalColorOfLabel, sizeConstant: 59)
//        self.outAnimatedLabel = AnimatedText(text: "OUT", color: self.originalColorOfLabel, frame: self.frame, shouldAnimateShadows: false)
        if let breakAnimatedLabel = self.breakAnimatedLabel {
            self.outAnimatedLabel?.calculatePosition(under: breakAnimatedLabel,
                                                     for: self.frame.size)
        }
        
        self.physicsWorld.gravity = CGVector()
        if let breakAnimatedLabel = self.breakAnimatedLabel {
            for letter in breakAnimatedLabel.sprites {
                self.addChild(letter)
            }
        }
        
        if let outAnimatedLabel = self.outAnimatedLabel {
            for letter in outAnimatedLabel.sprites {
                self.addChild(letter)
            }
        }
        
    }
    
    func pauseMenu() {
        guard !self.isPaused else {
            return
        }
        self.isPaused = true
        self.physicsWorld.speed = 0.0
        self.isHidden = true
        
    }
    func unpauseMenu() {
        guard self.isPaused else {
            return
        }
        self.isPaused = false
        self.physicsWorld.speed = 1.0
        self.isHidden = false
    }
    
    // функция обновлений
    override func update(_ currentTime: TimeInterval) {
        guard !self.isPaused else {
            return
        }
        self.breakAnimatedLabel?.ambientAnimating(
            colorToChange: self.colorOfLabelWhileAnimated,
            currentTime: currentTime)
        
        self.outAnimatedLabel?.ambientAnimating(
            colorToChange: self.colorOfLabelWhileAnimated,
            currentTime: currentTime)
    }
    
    // функции обработки нажатий
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // когда мы нажимаем на экран то появляется буква особого цвета
        guard !self.isPaused else {
            return
        }
        for touch in touches {
            self.touchDownOnLetter(touch)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.isPaused else {
            return
        }
        for touch in touches {
            self.touchProcessOnLetter(touch)
        }
    }
    
    // функция с генерацией частичек для заднего фона сцены
    private func createParticle()  {
        if let star = self.particle.copy() as? SKShapeNode {
            let randomGlowWidth = CGFloat(arc4random() % 7)
            star.glowWidth = randomGlowWidth
            
            let randomPosition = CGPoint(x: CGFloat(arc4random() % UInt32(self.frame.maxX)),
                                         y: self.frame.maxY)
            star.position = randomPosition
            star.run(SKAction.sequence([
                SKAction.move(to: CGPoint(x: randomPosition.x, y: 0.0), duration: 2.0),
                SKAction.removeFromParent()
            ]))
            
            self.addChild(star)
        }
        
    }
    
    // функция, которая вызывается, когда пользователь нажал на анимированную букву
    private func touchDownOnLetter(_ touch: UITouch) {
        if let breakLabel = self.breakAnimatedLabel?.sprites {
            for letter in breakLabel {
                if letter.contains(touch.location(in: self)) {
                    self.breakAnimatedLabel?.animate(
                        colorToChange: self.colorOfLabelWhileAnimated,
                        sprite: letter)
                }
            }
        }
        
        if let outAnimatedLabel = self.outAnimatedLabel {
            for letter in outAnimatedLabel.sprites {
                if letter.contains(touch.location(in: self)) {
                    self.outAnimatedLabel?.animate(
                        colorToChange: self.colorOfLabelWhileAnimated,
                        sprite: letter)
                }
            }
        }
    }
    // функция, которая вызывается, когда пользователь "провел" пальцем по анимированному тексту в игре
    private func touchProcessOnLetter(_ touch: UITouch) {
        if let breakLabel = self.breakAnimatedLabel?.sprites {
            for letter in breakLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.breakAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, sprite: letter)
                    }
                }
            }
        }
        if let outAnimatedLabel = self.outAnimatedLabel?.sprites {
            for letter in outAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.outAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, sprite: letter)
                    }
                }
            }
        }
    }
    
}
