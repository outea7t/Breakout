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
    private var breakoutAnimatedLabel: AnimatedText?
    private var arAnimatedLabel: AnimatedText?
    
    private var originalColorOfLabel = #colorLiteral(red: 0.03566226363, green: 0.9870653749, blue: 0.0007029015105, alpha: 1)
    private var colorOfLabelWhileAnimated = #colorLiteral(red: 0.1421280503, green: 0, blue: 1, alpha: 1)
    private var colorOfShadow = #colorLiteral(red: 0.05089633912, green: 0, blue: 0.3513666987, alpha: 1)
    deinit {
        
        print("ARMenuScene DEINITIALIZED")
    }
    override func didMove(to view: SKView) {
        let pointSize = self.frame.height/10
        self.animatedParticles = AnimatedParticles(text: "ARBreakout", pointSize: pointSize,enable3D: true)
        
        self.backgroundColor = .clear
        
        self.breakoutAnimatedLabel = AnimatedText(text: "Breakout",
                                                  color: self.originalColorOfLabel,
                                                  frame: self.frame,
                                                  shouldAnimateShadows: true,
                                                  shadowColor: self.colorOfShadow)
        self.breakoutAnimatedLabel?.calculatePosition(for: self.frame.size)
        
        
        
        self.arAnimatedLabel = AnimatedText(text: "AR!",
                                            color: self.originalColorOfLabel,
                                            frame: self.frame,
                                            shouldAnimateShadows: true,
                                            shadowColor: self.colorOfShadow)
        self.arAnimatedLabel?.calculatePosition(under: self.breakoutAnimatedLabel!, for: self.frame.size)
        
        if let breakoutAnimatedLabel = self.breakoutAnimatedLabel {
            for letter in breakoutAnimatedLabel.label {
                self.addChild(letter)
            }
        }
        
        if let arAnimatedLabel = self.arAnimatedLabel {
            for letter in arAnimatedLabel.label {
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
            self.breakoutAnimatedLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
            
            self.arAnimatedLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
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
        if let breakoutLabel = self.breakoutAnimatedLabel?.label {
            for letter in breakoutLabel {
                if letter.contains(touch.location(in: self)) {
                    self.breakoutAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                }
            }
        }
        
        if let arAnimatedLabel = self.arAnimatedLabel?.label {
            for letter in arAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.arAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                    }
                }
            }
        }
        
        
    }
    private func touchProcessOnLetter(_ touch: UITouch) {
        if let breakoutLabel = self.breakoutAnimatedLabel?.label {
            for letter in breakoutLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.breakoutAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                    }
                }
            }
        }
        
        if let arAnimatedLabel = self.arAnimatedLabel?.label {
            for letter in arAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.arAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                    }
                }
            }
        }
    }
}
