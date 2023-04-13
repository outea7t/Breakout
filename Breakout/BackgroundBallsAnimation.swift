//
//  BackgroundBallsAnimationFile.swift
//  Breakout
//
//  Created by Out East on 11.04.2023.
//

import Foundation
import SpriteKit
import UIKit

// сделай случайный скин для частичек
// случайный скин для мяча
// чтобы мячи летели по диагонали слева направо

/// класс с анимацией, который создает мячи, летящие по диагонали слева направо
class BackgroundBallAnimation {
    var balls = [Ball2D]()
    var numberOfBallsConstant: CGFloat = 1/3
    private let screenWidth: CGFloat
    private let screenHeight: CGFloat
    private var lastTime: TimeInterval = 0
    init(screenWidth: CGFloat, screenHeight: CGFloat) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }
    func update(currentTime: TimeInterval, nodeToAdd: SKNode) {
        if currentTime - self.lastTime >= self.numberOfBallsConstant {
            self.lastTime = currentTime
            self.addNewBall(nodeToAdd: nodeToAdd)
            for (i, ball) in balls.enumerated() {
                if ball.ball.position.x <= (self.screenWidth + ball.ballRadius) {
                    ball.update(currentTime: currentTime, gameNode: nodeToAdd)
                } else {
                    ball.ball.removeAllActions()
                    ball.ball.removeFromParent()
                    self.balls.remove(at: i)
                }
            }
        }
    }
    
    private func addNewBall(nodeToAdd: SKNode) {
        guard UserCustomization.maxBallSkinIndex != 0 && UserCustomization.maxParticleSkinIndex != 0 else {
            return
        }
        let oneTenth = self.screenHeight*0.4
        let randomPositionY = CGFloat.random(in: 0...(self.screenHeight))
        
        let ballStartPosition = CGPoint(x: -100, y: randomPositionY)
        let ballEndPosition = CGPoint(x: self.screenWidth*3, y: randomPositionY + oneTenth)
        
        let randomBallSkin = Int.random(in: 0..<UserCustomization.maxBallSkinIndex)
        let randomParticleSkin = Int.random(in: 0..<UserCustomization.maxParticleSkinIndex)
        
        let distance = sqrt(abs((ballEndPosition.x - ballStartPosition.x)*(ballEndPosition.x - ballStartPosition.x)) + abs((ballEndPosition.y - ballStartPosition.y) * (ballEndPosition.y - ballStartPosition.y)))
        let ballVelocity: CGFloat = 350
        
        let time = distance/ballVelocity
        
        let ball = Ball2D(frame: nodeToAdd.frame, ballRadius: 40)
        ball.setCertainBallSkin(skinIndex: randomBallSkin)
        ball.particle.setCertainParticleIndex(skinIndex: randomParticleSkin)
        ball.isAttachedToPaddle = false
        
        if ball.ball.parent == nil {
            nodeToAdd.addChild(ball.ball)
        }
        ball.ball.position = ballStartPosition
        let moveAction = SKAction.move(to: ballEndPosition, duration: time)
        ball.ball.run(moveAction)
        self.balls.append(ball)
    }
}
