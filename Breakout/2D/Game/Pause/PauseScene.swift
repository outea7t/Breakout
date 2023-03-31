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
    var animatedParticles: AnimatedParticles?
    
    let colorOfLabelWhileAnimated = #colorLiteral(red: 0.916108631, green: 0.447783801, blue: 0.168627451, alpha: 1)
    let originalColorOfLabel = #colorLiteral(red: 1, green: 0.8205810189, blue: 0, alpha: 1)
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        let pointSize = self.frame.height/10
        var colors = [UIColor]()
        
        colors = [#colorLiteral(red: 0, green: 1, blue: 0, alpha: 0.8), #colorLiteral(red: 1, green: 0.9465779662, blue: 0, alpha: 0.8), #colorLiteral(red: 0.0133848507, green: 0, blue: 1, alpha: 0.8), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.8), #colorLiteral(red: 1, green: 0, blue: 0.9527272582, alpha: 0.8)]
        self.animatedParticles = AnimatedParticles(text: "BREAKOUT", pointSize: pointSize, colors: colors, enable3D: false)
        
        let animatedPauseLabelColor = #colorLiteral(red: 1, green: 0.8205810189, blue: 0, alpha: 1)
        let p = UIImage(named: "PauseP.png")!
        let a = UIImage(named: "PauseA.png")!
        let u = UIImage(named: "PauseU.png")!
        let s = UIImage(named: "PauseS.png")!
        let e = UIImage(named: "PauseE.png")!
        let pauseImages = [p,a,u,s,e]

        self.animatedPauseLabel = AnimatedText(images: pauseImages, frame: self.frame, color: .white, sizeConstant: 67)
        
//        AnimatedText(text: "Pause", color: animatedPauseLabelColor, frame: self.frame, shouldAnimateShadows: false, sizeConstant: 105)
        
        self.animatedPauseLabel?.calculatePosition(for: self.frame.size, offsetY: 2.35)
        
        if let animatedPauseLabel = self.animatedPauseLabel {
            for letter in animatedPauseLabel.sprites {
                self.addChild(letter)
            }
        }
        self.addGlowToPauseLabel()
        
    }
    private func addGlowToPauseLabel() {
        guard let firstSprite = self.animatedPauseLabel?.sprites.first, let animatedPauseLabel = self.animatedPauseLabel else {
            return
            
        }
        let size = CGSize(width: animatedPauseLabel.width*1.2,
                          height: animatedPauseLabel.height*1.2)
        let spriteNode = SKSpriteNode(color: .white.withAlphaComponent(0.4), size: size)
        
        spriteNode.position = CGPoint(x: animatedPauseLabel.position.x, y: animatedPauseLabel.position.y)
        
        let blur = SKEffectNode()
        blur.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 100])
        blur.zPosition = -2
        blur.addChild(spriteNode)
        self.addChild(blur)
        
    }
    override func update(_ currentTime: TimeInterval) {
        self.animatedPauseLabel?.ambientAnimating(colorToChange: self.colorOfLabelWhileAnimated, currentTime: currentTime)
        self.animatedParticles?.update(currentTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchDownOnLetter(touch)
            if touch.location(in: self).y < self.frame.height*0.6 {
                
                HapticManager.collisionVibrate(with: .soft, 0.75)
                self.animatedParticles?.animate(touch, scene: self)
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchProcessOnLetter(touch)
            if touch.location(in: self).y < self.frame.height*0.6 {
                self.animatedParticles?.animate(touch, scene: self)
            }
        }
    }
    
    private func touchDownOnLetter(_ touch: UITouch) {
        self.animatedPauseLabel?.touchDown(touchPosition: touch.location(in: self), color: self.colorOfLabelWhileAnimated)
    }
    private func touchProcessOnLetter(_ touch: UITouch) {
        self.animatedPauseLabel?.touchProcess(touchPosition: touch.location(in: self), color: self.colorOfLabelWhileAnimated)
    }
}
