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
    private var colorOfLabelWhileAnimated = #colorLiteral(red: 0, green: 0.9536209702, blue: 0.9942776561, alpha: 1)
    private var colorOfShadow = #colorLiteral(red: 0.05089633912, green: 0, blue: 0.3513666987, alpha: 1)
    deinit {
        print("ARMenuScene DEINITIALIZED")
    }
    override func didMove(to view: SKView) {
        let pointSize = self.frame.height/10
        self.animatedParticles = AnimatedParticles(text: "ARBreakout", pointSize: pointSize,enable3D: true)
        
        self.backgroundColor = .clear
        
        let b = UIImage(named: "BAR.png")!
        let r = UIImage(named: "RAR.png")!
        let e = UIImage(named: "EAR.png")!
        let a = UIImage(named: "AAR.png")!
        let k = UIImage(named: "KAR.png")!
        let o = UIImage(named: "OAR.png")!
        let u = UIImage(named: "UAR.png")!
        let t = UIImage(named: "TAR.png")!
        let A = UIImage(named: "AAR.png")!
        let R = UIImage(named: "RAR.png")!
        let exMark = UIImage(named: "!AR.png")!
        let images_1 = [b,r,e,a,k]
        let images_2 = [o,u,t,A,R,exMark]
        
//        self.breakAnimatedLabel = AnimatedText(text: "BREAK",
//                                               color: self.originalColorOfLabel,
//                                               frame: self.frame,
//                                               shouldAnimateShadows: true,
//                                               shadowColor: self.colorOfShadow
        self.breakAnimatedLabel = AnimatedText(images: images_1, frame: self.frame, color: .white)
        self.breakAnimatedLabel?.calculatePosition(for: self.frame.size, offsetY: 2.2)
        
        
//        self.outARAnimatedLabel = AnimatedText(text: "OUT-AR!",
//                                               color: self.originalColorOfLabel,
//                                               frame: self.frame,
//                                               shouldAnimateShadows: true,
//                                               shadowColor: self.colorOfShadow
                                               
        self.outARAnimatedLabel = AnimatedText(images: images_2, frame: self.frame, color: .white)
        self.outARAnimatedLabel?.calculatePosition(under: self.breakAnimatedLabel!, for: self.frame.size)
        
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
