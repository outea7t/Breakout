//
//  PauseScene.swift
//  Breakout
//
//  Created by Out East on 29.07.2022.
//

import UIKit
import SpriteKit

class PauseScene: SKScene {
    var animatedPauseLabel: AnimatedText?
    
    let colorOfLabelWhileAnimated = #colorLiteral(red: 0.916108631, green: 0.447783801, blue: 0.168627451, alpha: 1)
    let originalColorOfLabel = #colorLiteral(red: 1, green: 0.8205810189, blue: 0, alpha: 1)
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        
        let animatedPauseLabelColor = #colorLiteral(red: 1, green: 0.8205810189, blue: 0, alpha: 1)
        self.animatedPauseLabel = AnimatedText(text: "Pause",
                                               color: animatedPauseLabelColor,
                                               frame: self.frame,
                                               shouldAnimateShadows: false,
                                               sizeConstant: 105)
        
        self.animatedPauseLabel?.calculatePosition(for: self.frame.size, offsetY: 2.8)
        
        if let animatedPauseLabel = self.animatedPauseLabel {
            for letter in animatedPauseLabel.label {
                self.addChild(letter)
            }
        }
        
        
    }
    override func update(_ currentTime: TimeInterval) {
        self.animatedPauseLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchDownOnLetter(touch)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchProcessOnLetter(touch)
        }
    }
    
    private func touchDownOnLetter(_ touch: UITouch) {
        if let breakoutLabel = self.animatedPauseLabel?.label {
            for letter in breakoutLabel {
                if letter.contains(touch.location(in: self)) {
                    self.animatedPauseLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                }
            }
        }
    }
    private func touchProcessOnLetter(_ touch: UITouch) {
        if let breakoutLabel = self.animatedPauseLabel?.label {
            for letter in breakoutLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.animatedPauseLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
                    }
                }
            }
        }
    }
}
