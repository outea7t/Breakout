//
//  StarScene.swift
//  Breakout
//
//  Created by Out East on 06.06.2023.
//

import UIKit
import SpriteKit
class StarScene: SKScene {
    var stars: Stars2D?
    override func didMove(to view: SKView) {
        print("entered")
        let timings = TimeForStars(_2StarTime: 50, _3StarTime: 50)
        
        self.backgroundColor = .clear
    }
    func updateStarTimings(timings: TimeForStars) {
        self.stars = Stars2D(timings: timings, frameSize: self.size)
        let centerOfStarSpriteKitScene = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.stars?.add(to: self, at: centerOfStarSpriteKitScene)
    }
    func setStarTimings(timings: TimeForStars) {
        self.stars?.timings = timings
    }
}
