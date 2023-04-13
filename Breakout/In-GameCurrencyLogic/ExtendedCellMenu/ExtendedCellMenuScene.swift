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
    var balls = [Ball2D]()
    var numberOfBallsConstant: CGFloat = 1/5
    private var lastTime: TimeInterval = 0
    var animation: BackgroundBallAnimation?
//    let node = SKSpriteNode(color: .clear, size: CGSize())
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.backgroundColor = .clear
        self.animation = BackgroundBallAnimation(screenWidth: view.frame.width, screenHeight: view.frame.height)
//        self.addChild(node)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if var animation = self.animation {
            animation.update(currentTime: currentTime, nodeToAdd: self)
        }
    }
}
