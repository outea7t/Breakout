//
//  ExtendedCellMenuScene.swift
//  Breakout
//
//  Created by Out East on 13.04.2023.
//

import Foundation
import UIKit
import SpriteKit

class ExtendedCellMenuScene: SKScene {
    var animation: BackgroundBallAnimation?
//    let node = SKSpriteNode(color: .clear, size: CGSize())
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.backgroundColor = .clear
        self.animation = BackgroundBallAnimation(screenWidth: view.frame.width, screenHeight: view.frame.height)
//        self.addChild(node)
    }
    
    override func update(_ currentTime: TimeInterval) {
        animation?.update(currentTime: currentTime, nodeToAdd: self)
    }
    func pause() {
        
        self.animation?.isPaused = true
        guard let balls = self.animation?.balls else {
            return
        }
        for ball in balls {
            ball.ball.isPaused = true
            
        }
    }
    func unpause() {
        self.animation?.isPaused = false
        guard let balls = self.animation?.balls else {
            return
        }
        for ball in balls {
            ball.ball.isPaused = false
        }
    }
}
