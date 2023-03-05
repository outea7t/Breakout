//
//  ARPauseScene.swift
//  Breakout
//
//  Created by Out East on 26.02.2023.
//

import UIKit
import SpriteKit

class ARPauseScene: SKScene {
    var pauseAnimatedLabel: AnimatedText?
    
    let mainPauseLabelColor = #colorLiteral(red: 1, green: 0.8191056848, blue: 0, alpha: 1)
    let shadowPauseLabelColor = #colorLiteral(red: 0.3743131161, green: 0.3061052263, blue: 0.04920960218, alpha: 1)
    let colorToChange = #colorLiteral(red: 1, green: 0.5343436599, blue: 0, alpha: 1)
    override func didMove(to view: SKView) {
        
        
        self.pauseAnimatedLabel = AnimatedText(
            text: "PAUSE",
            color: mainPauseLabelColor,
            frame: self.frame,
            shouldAnimateShadows: true,
            sizeConstant: 105,
            shadowColor: shadowPauseLabelColor
        )
        
        pauseAnimatedLabel?.calculatePosition(for: self.frame.size, offsetY: 2.5)
        
        if let pauseAnimatedLabel = self.pauseAnimatedLabel {
            for letter in pauseAnimatedLabel.label {
                self.addChild(letter)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.pauseAnimatedLabel?.ambientAnimating(colorToChange: colorToChange, currentTime: currentTime)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchDownOnPause(touch)
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchProcessOnPause(touch)
        }
    }
    private func touchDownOnPause(_ touch: UITouch) {
        if let pauseAnimatedLabel = self.pauseAnimatedLabel?.label {
            for letter in pauseAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    self.pauseAnimatedLabel?.animate(
                        colorToChange: self.colorToChange,
                        letter: letter)
                }
            }
        }
    }
    private func touchProcessOnPause(_ touch: UITouch) {
        if let pauseAnimatedLabel = pauseAnimatedLabel?.label {
            for letter in pauseAnimatedLabel {
                if letter.contains(touch.location(in: self)) {
                    if !letter.hasActions() {
                        self.pauseAnimatedLabel?.animate(
                            colorToChange: self.colorToChange,
                            letter: letter)
                    }
                }
            }
        }
    }
    
}

