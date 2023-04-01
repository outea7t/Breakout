//
//  ARMenuScene.swift
//  Breakout
//
//  Created by Out East on 15.11.2022.
//

import UIKit
import SpriteKit
import Foundation

class ARMenuScene: SKScene {
    var animatedParticles: AnimatedParticles?
    
    // анимированный текст надписи Breakout AR
    private var breakAnimatedLabel: AnimatedText?
    private var outARAnimatedLabel: AnimatedText?
    
    private var originalColorOfLabel = #colorLiteral(red: 0.03566226363, green: 0.9870653749, blue: 0.0007029015105, alpha: 1)
    private var colorOfLabelWhileAnimated = #colorLiteral(red: 0, green: 0.1004967913, blue: 1, alpha: 1)
    private var colorOfShadow = #colorLiteral(red: 0.05089633912, green: 0, blue: 0.3513666987, alpha: 1)
    deinit {
        print("ARMenuScene DEINITIALIZED")
    }
    override func didMove(to view: SKView) {
        let pointSize = self.frame.height/10
        self.animatedParticles = AnimatedParticles(text: "ARBreakout",
                                                   pointSize: pointSize,
                                                   colors: [colorOfLabelWhileAnimated],
                                                   enable3D: true)
        
        self.backgroundColor = .clear
        
        let b = UIImage(named: "B.png")!
        let r = UIImage(named: "R.png")!
        let e = UIImage(named: "E.png")!
        let a = UIImage(named: "A.png")!
        let k = UIImage(named: "K.png")!
        let o = UIImage(named: "O.png")!
        let u = UIImage(named: "U.png")!
        let t = UIImage(named: "T.png")!
        let images_1 = [b,r,e,a,k]
        let images_2 = [o,u,t]
        
//        self.breakAnimatedLabel = AnimatedText(text: "BREAK",
//                                               color: self.originalColorOfLabel,
//                                               frame: self.frame,
//                                               shouldAnimateShadows: true,
//                                               shadowColor: self.colorOfShadow
        self.breakAnimatedLabel = AnimatedText(images: images_1, frame: self.frame, color: .white, sizeConstant: 59)
        self.breakAnimatedLabel?.calculatePosition(for: self.frame.size, offsetY: 2.2)
        
        
//        self.outARAnimatedLabel = AnimatedText(text: "OUT-AR!",
//                                               color: self.originalColorOfLabel,
//                                               frame: self.frame,
//                                               shouldAnimateShadows: true,
//                                               shadowColor: self.colorOfShadow
                                               
        self.outARAnimatedLabel = AnimatedText(images: images_2, frame: self.frame, color: .white, sizeConstant: 59)
        self.outARAnimatedLabel?.calculatePosition(under: self.breakAnimatedLabel!, for: self.frame.size)
        
        // загружаем маленькую надпись AR! и располагаем ее в парвом верхнем углу последней букву OUT
        let arLabelImage = UIImage(named: "AR!Label.png")
        if let arLabelImage = arLabelImage {
            let textureForArLabelImage = SKTexture(image: arLabelImage)
            let widthToHeightConstant = arLabelImage.size.width/arLabelImage.size.height
            if let lastLetter = self.outARAnimatedLabel?.sprites.last {
                let heightForArLabelImage = lastLetter.size.height/2.2
                let sizeForArLabelImage = CGSize(width: heightForArLabelImage*widthToHeightConstant,
                                                 height: heightForArLabelImage)
                let arSprite = SKSpriteNode(texture: textureForArLabelImage,
                                            color: .white,
                                            size: sizeForArLabelImage)
                
                
                let positionForArSprite = CGPoint(x: lastLetter.position.x + lastLetter.size.width + sizeForArLabelImage.width/5,
                                                  y: lastLetter.position.y + lastLetter.size.height)
                
                arSprite.position = positionForArSprite
                self.addChild(arSprite)
            }
            
        }
        
        
        if let breakAnimatedLabel = self.breakAnimatedLabel {
            for letter in breakAnimatedLabel.sprites {
                self.addChild(letter)
            }
        }
        
        if let outARAnimatedLabel = self.outARAnimatedLabel {
            for letter in outARAnimatedLabel.sprites {
                self.addChild(letter)
            }
        }
        
    }
    func pauseScene() {
        
        self.isPaused = true
    }
    func unpauseScene() {
        self.isPaused = false
    }
    override func update(_ currentTime: TimeInterval) {
        if !self.isPaused {
            self.animatedParticles?.update(currentTime)
            self.breakAnimatedLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
            
            self.outARAnimatedLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isPaused {
            for touch in touches {
                if touch.location(in: self).y < self.frame.height*0.65 {
                    HapticManager.collisionVibrate(with: .soft, 0.75)
                    self.animatedParticles?.animate(touch, scene: self)
                }
                self.touchDownOnLetter(touch)
            }
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isPaused {
            for touch in touches {
                if touch.location(in: self).y < self.frame.height*0.65 {
                    self.animatedParticles?.animate(touch, scene: self)
                }
                self.touchProcessOnLetter(touch)
            }
        }
    }
    
    private func touchDownOnLetter(_ touch: UITouch) {
        if let breakAnimatedLabel = self.breakAnimatedLabel?.sprites {
            for letter in breakAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    self.breakAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, sprite: letter)
                }
            }
        }
        
        if let outARAnimatedLabel = self.outARAnimatedLabel?.sprites {
            for letter in outARAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.outARAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, sprite: letter)
                    }
                }
            }
        }
        
        
    }
    private func touchProcessOnLetter(_ touch: UITouch) {
        if let breakAnimatedLabel = self.breakAnimatedLabel?.sprites {
            for letter in breakAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.breakAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, sprite: letter)
                    }
                }
            }
        }
        
        if let outARAnimatedLabel = self.outARAnimatedLabel?.sprites {
            for letter in outARAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.outARAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, sprite: letter)
                    }
                }
            }
        }
    }
}
