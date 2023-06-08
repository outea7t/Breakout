//
//  SettingsScene.swift
//  Breakout
//
//  Created by Out East on 07.06.2023.
//

import UIKit
import SpriteKit

class SettingsScene: SKScene {
    
    private var animatedParticles: AnimatedParticles?
    private var settingsAnimatedLabel: AnimatedText?
    private var musicAnimatedLabel: AnimatedText?
    private var soundsAnimatedLabel: AnimatedText?
    private let colorOfLabelWhileAnimated = #colorLiteral(red: 0.2862745098, green: 0.9960784314, blue: 0.4862745098, alpha: 1)
    
    var musicLabelPosition: CGPoint?
    var soundsLabelPosition: CGPoint?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.backgroundColor = .clear
        
        let pointSize = self.frame.height/10
        self.animatedParticles = AnimatedParticles(text: "Breakout", pointSize: pointSize, colors: [#colorLiteral(red: 0.420588553, green: 0, blue: 1, alpha: 1)], enable3D: true)
        
        self.settingsAnimatedLabel = AnimatedText(text: "SETTINGS",
                                                  color: .white,
                                                  frame: self.frame,
                                                  shouldAnimateShadows: false,
                                                  sizeConstant: 65)
        self.settingsAnimatedLabel?.calculatePosition(for: self.frame.size, offsetY: 3.8)
        
        self.musicAnimatedLabel = AnimatedText(text: "Music", color: .white, frame: self.frame, shouldAnimateShadows: false, sizeConstant: 50)
        self.soundsAnimatedLabel = AnimatedText(text: "Sounds", color: .white, frame: self.frame, shouldAnimateShadows: false, sizeConstant: 50)
        
        
        if let settingsAnimatedLabel = self.settingsAnimatedLabel {
            for letter in settingsAnimatedLabel.label {
//                self.addChild(letter)
            }
        }
        
        if let musicLabelPosition = self.musicLabelPosition {
            let actualPosition = CGPoint(x: musicLabelPosition.x,
                                         y: self.frame.height - musicLabelPosition.y - musicAnimatedLabel!.height)
            self.musicAnimatedLabel?.calculatePosition(for: self.frame.size, in: musicLabelPosition)
            
            if let musicAnimatedLabel = self.musicAnimatedLabel {
                for letter in musicAnimatedLabel.label {
//                    self.addChild(letter)
                }
            }
        }
        
        if let soundsLabelPosition = self.soundsLabelPosition {
            let actualPosition = CGPoint(x: soundsLabelPosition.x,
                                         y: self.frame.height - soundsLabelPosition.y - soundsAnimatedLabel!.height)
            self.soundsAnimatedLabel?.calculatePosition(for: self.frame.size, in: soundsLabelPosition)
            
            if let soundsAnimatedLabel = self.soundsAnimatedLabel {
                for letter in soundsAnimatedLabel.label {
//                    self.addChild(letter)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        self.animatedParticles?.update(currentTime)
        self.settingsAnimatedLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
        self.musicAnimatedLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
        self.soundsAnimatedLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for touch in touches {
            self.touchDownOnLetter(touch)
            if touch.location(in: self).y < self.frame.height*0.6 {
                
                HapticManager.collisionVibrate(with: .soft, 0.75)
                self.animatedParticles?.animate(touch, scene: self)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            self.touchProcessOnLetter(touch)
            // когда мы двигаем пальцем по экрану, то создается буква особого цвета
            if touch.location(in: self).y < self.frame.height*0.6 {
                self.animatedParticles?.animate(touch, scene: self)
            }
        }
    }
    
    
    // функция, которая вызывается, когда пользователь нажал на анимированную букву
    private func touchDownOnLetter(_ touch: UITouch) {
        if let settingsAnimatedLabel = self.settingsAnimatedLabel?.label {
            for letter in settingsAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    self.settingsAnimatedLabel?.animate(
                        colorToChange: self.colorOfLabelWhileAnimated,
                        letter: letter)
                }
            }
        }
        
        if let musicAnimatedLabel = self.musicAnimatedLabel?.label {
            for letter in musicAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    self.musicAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                }
            }
        }
        if let soundsAnimatedLabel = self.soundsAnimatedLabel?.label {
            for letter in soundsAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    self.soundsAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                }
            }
        }
    }
    // функция, которая вызывается, когда пользователь "провел" пальцем по анимированному тексту в игре
    private func touchProcessOnLetter(_ touch: UITouch) {
        if let settingsAnimatedLabel = self.settingsAnimatedLabel?.label {
            for letter in settingsAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.settingsAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                    }
                }
            }
        }
        if let musicAnimatedLabel = self.musicAnimatedLabel?.label {
            for letter in musicAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    self.musicAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                }
            }
        }
        if let soundsAnimatedLabel = self.soundsAnimatedLabel?.label {
            for letter in soundsAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    self.soundsAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                }
            }
        }
    }
}
