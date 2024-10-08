//
//  MenuScene.swift
//  MyFirstIOSProj
//
//  Created by Out East on 22.07.2022.
//

import SpriteKit
import CoreAudioTypes

class MenuScene: SKScene {
    // для интерактивности - спиннеры
    private var animatedParticles: AnimatedParticles?
    
    private let particle = SKShapeNode(circleOfRadius: 2.0)
    private var lastTime = TimeInterval(0)
    private var particlePerSecond = CGFloat()
    // анимированное название игры
    private var breakAnimatedLabel: AnimatedText?
    private var outAnimatedLabel: AnimatedText?
    
//    #colorLiteral(red: 0, green: 0.941948235, blue: 0.4499601722, alpha: 1)
    private let colorOfLabelWhileAnimated = #colorLiteral(red: 0, green: 0.0002773534216, blue: 1, alpha: 1)
    
    private let originalColorOfLabel = #colorLiteral(red: 0, green: 0.981975615, blue: 0.2249540389, alpha: 1)
    
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        
        self.physicsWorld.gravity = CGVector()
        // размер частичек будет особенным для каждого устройства
        let pointSize = self.frame.height/10
        
        self.animatedParticles = AnimatedParticles(text: "Breakout", pointSize: pointSize, enable3D: false)
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
//        self.breakAnimatedLabel = AnimatedText(images: images_1, frame: self.frame, color: self.originalColorOfLabel)
        self.breakAnimatedLabel = AnimatedText(text: "BREAK", color: self.originalColorOfLabel, frame: self.frame, shouldAnimateShadows: false)
        
        self.breakAnimatedLabel?.calculatePosition(for: self.frame.size)
        
        let images_2 = [o,u,t]
//        self.outAnimatedLabel = AnimatedText(images: images_2, frame: self.frame, color: self.originalColorOfLabel)
        self.outAnimatedLabel = AnimatedText(text: "OUT", color: self.originalColorOfLabel, frame: self.frame, shouldAnimateShadows: false)
        if let breakAnimatedLabel = self.breakAnimatedLabel {
            self.outAnimatedLabel?.calculatePosition(under: breakAnimatedLabel,
                                                     for: self.frame.size)
        }
        
        if let breakAnimatedLabel = self.breakAnimatedLabel {
            for letter in breakAnimatedLabel.label {
                self.addChild(letter)
            }
        }
        
        if let outAnimatedLabel = self.outAnimatedLabel {
            for letter in outAnimatedLabel.label {
                self.addChild(letter)
            }
        }
        
    }
    func pauseMenu() {
        self.isPaused = true
        self.physicsWorld.speed = 0.0
        self.isHidden = true
        
    }
    func unpauseMenu() {
        self.isPaused = false
        self.physicsWorld.speed = 1.0
        self.isHidden = false
    }
    
    // функция обновлений
    override func update(_ currentTime: TimeInterval) {
        if !self.isPaused {
            //        if currentTime - self.lastTime > self.particlePerSecond {
            //            self.createParticle()
            //            self.lastTime = currentTime
            //        }
            
            self.animatedParticles?.update(currentTime)
            self.breakAnimatedLabel?.ambientAnimating(
                colorToChange: self.colorOfLabelWhileAnimated,
                currentTime: currentTime)
            
            self.outAnimatedLabel?.ambientAnimating(
                colorToChange: self.colorOfLabelWhileAnimated,
                currentTime: currentTime)
        }
    }
    
    // функции обработки нажатий
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // когда мы нажимаем на экран то появляется буква особого цвета
        if !self.isPaused {
            for touch in touches {
                self.touchDownOnLetter(touch)
                if touch.location(in: self).y < self.frame.height*0.6 {
                    
                    HapticManager.collisionVibrate(with: .soft, 0.75)
                    self.animatedParticles?.animate(touch, scene: self)
                }
            }
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isPaused {
            for touch in touches {
                self.touchProcessOnLetter(touch)
                // когда мы двигаем пальцем по экрану, то создается буква особого цвета
                if touch.location(in: self).y < self.frame.height*0.6 {
                    self.animatedParticles?.animate(touch, scene: self)
                }
            }
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
    
    private func touchDownOnLetter(_ touch: UITouch) {
        if let breakLabel = self.breakAnimatedLabel?.label {
            for letter in breakLabel {
                if letter.contains(touch.location(in: self)) {
                    self.breakAnimatedLabel?.animate(
                        colorToChange: self.colorOfLabelWhileAnimated,
                        letter: letter)
                }
            }
        }
        
        if let outAnimatedLabel = self.outAnimatedLabel {
            for letter in outAnimatedLabel.label {
                if letter.contains(touch.location(in: self)) {
                    self.outAnimatedLabel?.animate(
                        colorToChange: self.colorOfLabelWhileAnimated,
                        letter: letter)
                }
            }
        }
    }
    private func touchProcessOnLetter(_ touch: UITouch) {
        if let breakLabel = self.breakAnimatedLabel?.label {
            for letter in breakLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.breakAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                    }
                }
            }
        }
        if let outAnimatedLabel = self.outAnimatedLabel?.label {
            for letter in outAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.outAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                    }
                }
            }
        }
    }
    
}
