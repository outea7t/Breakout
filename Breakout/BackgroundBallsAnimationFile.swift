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
struct BackgroundBallAnimation {
    var balls = [Ball2D]()
    var numberOfBallsConstant: CGFloat = 1/10
    private let screenWidth: CGFloat
    private let screenHeight: CGFloat
    
    init(screenWidth: CGFloat, screenHeight: CGFloat) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        
    }
}
