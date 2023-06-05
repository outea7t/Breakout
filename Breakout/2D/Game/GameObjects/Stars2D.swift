//
//  Stars.swift
//  Breakout
//
//  Created by Out East on 10.05.2023.
//

import Foundation
import SpriteKit

struct TimeForStars {
    let _1StarTime: TimeInterval
    let _2StarTime: TimeInterval
    let _3StarTime: TimeInterval
}
class Stars2D {
    /// количество звезд, которое в данный момент имеет пользователь
    var numberOfStars: Int
    
    private let _1StarCropNode = SKCropNode()
    private let _2StarCropNode = SKCropNode()
    private let _3StarCropNode = SKCropNode()
    
    private let _1StarRectangle: SKSpriteNode
    private let _2StarRectangle: SKSpriteNode
    private let _3StarRectangle: SKSpriteNode
    
    private let timings: TimeForStars
    private var sizeOfStar = CGSize()
    
    init(timings: TimeForStars, frameSize: CGSize) {
        self._1StarRectangle = SKSpriteNode()
        self._2StarRectangle = SKSpriteNode()
        self._3StarRectangle = SKSpriteNode()
        self.timings = timings
        self.numberOfStars = 3
        
        let starSize = frameSize.width * 0.2209
        self.sizeOfStar = CGSize(width: starSize, height: starSize)
        let yellowStarColor = #colorLiteral(red: 1, green: 0.7215686275, blue: 0, alpha: 1)
        
        self._1StarRectangle.color = yellowStarColor
        self._1StarRectangle.size = CGSize(width: starSize, height: starSize)
        self._1StarCropNode.addChild(_1StarRectangle)
        
        self._2StarRectangle.color = yellowStarColor
        self._2StarRectangle.size = CGSize(width: starSize, height: starSize)
        self._2StarCropNode.addChild(_2StarRectangle)
        
        self._3StarRectangle.color = yellowStarColor
        self._3StarRectangle.size = CGSize(width: starSize, height: starSize)
        self._3StarCropNode.addChild(_3StarRectangle)
        
        self._1StarCropNode.zPosition = -1
        self._2StarCropNode.zPosition = -1
        self._3StarCropNode.zPosition = -1
        
        let maskTexture = SKTexture(imageNamed: "singleStar.png")
        let maskNode = SKSpriteNode(texture: maskTexture, color: .white, size: CGSize(width: starSize, height: starSize))
        self._1StarCropNode.maskNode = maskNode
        self._2StarCropNode.maskNode = maskNode
        self._3StarCropNode.maskNode = maskNode
        
    }
    
    func add(to node: SKNode, scene: SKScene, positionOfBallAttachedToPaddle: CGPoint) {
        // сначала рассчитываем позицию 2-ой звезды (она посередине экрана) а затем считаем позицию остальных звезд относительно нее
        let _2StarPosition = CGPoint(x: scene.frame.midX,
                                     y: positionOfBallAttachedToPaddle.y + self.sizeOfStar.width/2.0)
        self._2StarCropNode.position = _2StarPosition
        
        let _1StarPosition = CGPoint(x: scene.frame.midX - self.sizeOfStar.width,
                                     y: _2StarPosition.y + self.sizeOfStar.height * 0.15)
        self._1StarCropNode.position = _1StarPosition
        
        let _3StarPosition = CGPoint(x: scene.frame.midX + self.sizeOfStar.width,
                                     y: _1StarPosition.y)
        self._3StarCropNode.position = _3StarPosition
        
        node.addChild(_1StarCropNode)
        node.addChild(_2StarCropNode)
        node.addChild(_3StarCropNode)
        
        let _3StarFadingAction = SKAction.move(by: CGVector(dx: -self.sizeOfStar.width, dy: 0),
                                               duration: self.timings._3StarTime)
        let _2StarFadingAction = SKAction.move(by: CGVector(dx: -self.sizeOfStar.width, dy: 0),
                                               duration: self.timings._2StarTime)
        let _1StarFadingAction = SKAction.move(by: CGVector(dx: -self.sizeOfStar.width, dy: 0),
                                               duration: self.timings._1StarTime)
        
        self._3StarRectangle.run(_3StarFadingAction) { [weak self] in
            self?.numberOfStars = 2
            self?._2StarRectangle.run(_2StarFadingAction) { [weak self] in
                self?.numberOfStars = 1
            }
        }
    }
    func clearActions() {
        self._1StarRectangle.removeAllActions()
        self._1StarRectangle.position = CGPoint()
        
        self._2StarRectangle.removeAllActions()
        self._2StarRectangle.position = CGPoint()
        
        self._3StarRectangle.removeAllActions()
        self._3StarRectangle.position = CGPoint()
    }
    func startActions() {
        let _3StarFadingAction = SKAction.move(by: CGVector(dx: -self.sizeOfStar.width, dy: 0),
                                               duration: self.timings._3StarTime)
        let _2StarFadingAction = SKAction.move(by: CGVector(dx: -self.sizeOfStar.width, dy: 0),
                                               duration: self.timings._2StarTime)
        let _1StarFadingAction = SKAction.move(by: CGVector(dx: -self.sizeOfStar.width, dy: 0),
                                               duration: self.timings._1StarTime)
        
        self._3StarRectangle.run(_3StarFadingAction) { [weak self] in
            self?.numberOfStars = 2
            self?._2StarRectangle.run(_2StarFadingAction) { [weak self] in
                self?.numberOfStars = 1
            }
        }
    }
}
