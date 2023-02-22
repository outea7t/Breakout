//
//  AnimatedText.swift
//  Breakout
//
//  Created by Out East on 31.08.2022.
//

import Foundation
import SpriteKit
import UIKit

struct AnimatedText {
    /// отображаемый текст
    private let textOfLabel: String
    /// массив с нодами, каждая из который отражает определенный символ
    var label = [SKLabelNode]()
    var sprites = [SKSpriteNode]()
    var shadowColor = UIColor()
    /// изначальный цвет
    private var originalColor: UIColor
    /// для того, чтобы увеличивать шрифт во время увеличения размера viewPort
    private let preferBiggerSize: Bool
    /// нужно ли анимировать тени текста
    private let shouldAnimateShadows: Bool
    /// последний раз, когда текст анимировался в фоновом режиме
    var lastAmbientAnimationTime = TimeInterval()
    var currentTime = TimeInterval()
    
    private var positions = [CGPoint]()
    
    init(text: String,
         color: UIColor,
         frame: CGRect,
         shouldAnimateShadows: Bool,
         preferBiggerSize: Bool = false,
         shadowColor: UIColor? = nil
    ) {
        self.shouldAnimateShadows = shouldAnimateShadows
        self.textOfLabel = text
        self.originalColor = color
        self.preferBiggerSize = preferBiggerSize
        if let shadowColor = shadowColor {
            self.shadowColor = shadowColor
        }
        // настраиваем интерактивную надпись-название игры
        for symbol in text {
            var letter: SKLabelNode?
            
            if self.label.count > 0 {
                letter = self.initLetter(String(symbol), frame: frame)
            } else {
                letter = self.initLetter(String(symbol), frame: frame)
            }
            if let letter = letter {
                self.label.append(letter)
            }
        }
    }
    init(images: [UIImage], frame: CGRect, color: UIColor) {
        self.shouldAnimateShadows = false
        self.textOfLabel = ""
        self.originalColor = color
        self.preferBiggerSize = false
        self.shadowColor = .clear
        // настраиваем интерактивную надпись-название игры
        for image in images {
            let sprite = self.initSprite(image, frame: frame)
            self.sprites.append(sprite)
        }
    }
    
    
    mutating func animate(colorToChange: UIColor, letter: SKLabelNode) {
        var r = CGFloat()
        var g = CGFloat()
        var b = CGFloat()
        var a = CGFloat()
        
        colorToChange.getRed(&r, green: &g, blue: &b, alpha: &a)
        print(r,g,b,a)
        
        let animation = createAnimation(colorToChange: colorToChange)
        letter.run(animation)
        
        
        // обновляем время для анимации
        self.lastAmbientAnimationTime = self.currentTime
    }
    
    mutating func animate(colorToChange: UIColor, sprite: SKSpriteNode) {
        var r = CGFloat()
        var g = CGFloat()
        var b = CGFloat()
        var a = CGFloat()
        
        colorToChange.getRed(&r, green: &g, blue: &b, alpha: &a)
        print(r,g,b,a)
        
        let animation = createAnimation(colorToChange: colorToChange)
        sprite.run(animation)
        
        
        // обновляем время для анимации
        self.lastAmbientAnimationTime = self.currentTime
    }
    
    /// когда мы не касаемся до текста некоторое время, то анимация проигрывается сама по себе
    mutating func ambientAnimating(colorToChange: UIColor, currentTime: TimeInterval) {
        self.currentTime = currentTime
        
        if self.currentTime - self.lastAmbientAnimationTime > 7.0 {
            let animation = self.createAnimation(colorToChange: colorToChange)
            var waitTime = 0.0
            for letter in self.label {
                let sequence = SKAction.sequence([
                    .wait(forDuration: waitTime),
                    animation
                ])
                letter.run(sequence)
                waitTime += 0.1
            }
            waitTime = 0.0
            for sprite in sprites {
                let sequence = SKAction.sequence([
                    .wait(forDuration: waitTime),
                    animation
                ])
                sprite.run(sequence)
                waitTime += 0.1
            }
            
            self.lastAmbientAnimationTime = currentTime
            print(currentTime)
        }
        
    }
    /// расчитываем позицию текста ниже другого анимированного текста
    mutating func calculatePosition(under animatedLabel: AnimatedText, for frameSize: CGSize) {
        if animatedLabel.sprites.count > 0 {
            var lengthOfWord = 0.0
            let heighOfWord = self.sprites[0].frame.height
            
            for l in self.sprites {
                lengthOfWord += l.frame.width
            }
            
            let offsetX = (frameSize.width - lengthOfWord)/2.0
            
            let offsetY = animatedLabel.sprites[0].position.y - animatedLabel.sprites[0].frame.height/2.0 - heighOfWord/2.0 - heighOfWord / 3.0
            
            self.calculatePosition(with: offsetX, offsetY: offsetY)
        }
        
        if animatedLabel.label.count > 0 {
            var lengthOfWord = 0.0
            let heighOfWord = self.label[0].frame.height
            
            for l in self.label {
                lengthOfWord += l.frame.width
            }
            
            let offsetX = (frameSize.width - lengthOfWord)/2.0
            
            let offsetY = animatedLabel.label[0].position.y - animatedLabel.label[0].frame.height/2.0 - heighOfWord/2.0 - heighOfWord / 3.0
            
            self.calculatePosition(with: offsetX, offsetY: offsetY)
        }
    }
    private mutating func calculatePosition(with offsetX: CGFloat, offsetY: CGFloat) {
        for (index, letter) in self.label.enumerated() {
            if index == 0 {
                letter.position = CGPoint(x: offsetX + self.label[0].frame.width/2.0, y: offsetY)
            } else {
                letter.position = CGPoint(
                    // чуть больше чем нужно, чтобы буквы были чуть дальше друг от друга в связи с шрифтом Bungee
                    x: self.label[index-1].position.x + letter.frame.width * 0.5 + self.label[index-1].frame.width*0.5 + letter.frame.width*0.05,
                    y: offsetY)
            }
        }
        
        for (index, sprite) in self.sprites.enumerated() {
            if index == 0 {
                sprite.position = CGPoint(x: offsetX + self.sprites[0].frame.width/2.0, y: offsetY)
            } else {
                sprite.position = CGPoint(
                    // чуть больше чем нужно, чтобы буквы были чуть дальше друг от друга в связи с шрифтом Bungee
                    x: self.sprites[index-1].position.x + sprite.frame.width * 0.5 + self.sprites[index-1].frame.width*0.5 + sprite.frame.width*0.05,
                    y: offsetY)
                self.positions.append(sprite.position)
            }
        }
    }
    /// расчитываем позицию текста (всегда находиться в верхней части экрана и в середине)
    mutating func calculatePosition(for frameSize: CGSize) {
        var lengthOfWord = 0.0
        if !self.sprites.isEmpty {
            let heighOfWord = self.sprites[0].frame.height
            
            for l in self.sprites {
                lengthOfWord += l.frame.width
            }
            
            let offsetX = (frameSize.width - lengthOfWord)/2.0
            
            var offsetY = frameSize.height - heighOfWord*2.5
            
            if self.preferBiggerSize {
                offsetY = frameSize.height - heighOfWord * 2.75
            }
            self.calculatePosition(with: offsetX, offsetY: offsetY)
        }
        
        if !self.label.isEmpty {
            let heighOfWord = self.label[0].frame.height
            
            for l in self.label {
                lengthOfWord += l.frame.width
            }
            
            let offsetX = (frameSize.width - lengthOfWord)/2.0
            
            var offsetY = frameSize.height - heighOfWord*2.5
            
            if self.preferBiggerSize {
                offsetY = frameSize.height - heighOfWord * 2.75
            }
            self.calculatePosition(with: offsetX, offsetY: offsetY)
        }
    }
    /// функция, которая запускает анимацию после того, как пользователь на нее нажал
//    private func touchDownOnLetter(_ touch: UITouch, view: UI) {
//
//        for letter in self.label {
//            if letter.contains(touch.location(in: self)) {
//                self.label.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
//            }
//        }
//    }
//    /// функция, которая запускает анимацию букв, по которым провел пользователь
//    private func touchProcessOnLetter(_ touch: UITouch) {
//        if let breakoutLabel = self.breakoutAnimatedLabel?.label {
//            for letter in breakoutLabel {
//                if letter.contains(touch.location(in: self)) {
//                    if !letter.hasActions() {
//                        self.breakoutAnimatedLabel?.animate(colorToChange: self.colorOfLabelWhileAnimated, letter: letter)
//                    }
//                }
//            }
//        }
//    }
    /// функция, которая возвращает анимацию, которую можно проиграть на любой букве
    /// сделано для того, чтобы не дублировать код при создании ambientAnimation
    private func createAnimation(colorToChange: UIColor) -> SKAction {
        let downSize_0 = SKAction.group([
            SKAction.scaleX(to: 1.4, duration: 0.22),
            SKAction.scaleY(to: 0.7, duration: 0.22)
        ])
        
        
        let upSize_0 = SKAction.group([
            SKAction.scaleX(to: 0.7, duration: 0.13),
            SKAction.scaleY(to: 1.35, duration: 0.13)
        ])
        
        
        let downSize_1 = SKAction.group([
            SKAction.scaleX(to: 1.15, duration: 0.12),
            SKAction.scaleY(to: 0.85, duration: 0.12)
        ])
                                         
        let upSize_1 = SKAction.group([
            SKAction.scaleX(to: 0.9, duration: 0.12),
            SKAction.scaleY(to: 1.1, duration: 0.12)
        ])
        
        let normalSize = SKAction.group([
            SKAction.scaleX(to: 1, duration: 0.1),
            SKAction.scaleY(to: 1, duration: 0.1)
        ])
        
        let resizeSequence = SKAction.sequence([
            downSize_0,
            upSize_0,
            downSize_1,
            upSize_1,
            normalSize
        ])
        
        
        let toUserColor = SKAction.colorize(
            with: colorToChange,
            colorBlendFactor: 1.0,
            duration: 0.20)
        let wait = SKAction.wait(forDuration: 0.35)
        
        
        let toOriginalColor = SKAction.colorize(
            with: self.originalColor,
            colorBlendFactor: 1.0,
            duration: 0.15)
        
        let colorizeSequence = SKAction.sequence([
            toUserColor,
            wait,
            toOriginalColor
        ])
        
        
//        let keepPosition = SKAction.move(to: self.positions[0], duration: 0.0)
        let resultAction = SKAction.group([
            resizeSequence,
            colorizeSequence
//            keepPosition
        ])
        return resultAction
    }
    private func initSprite(_ image: UIImage, frame: CGRect) -> SKSpriteNode {
        let texture = SKTexture(image: image)
        
        
        let s = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: 65, height: 65))
        
        
        s.colorBlendFactor = 0.5
        s.position = CGPoint()
        
        
        return s
    }
    /// расчитываем размер буквы
    private func initLetter(_ symbol: String, frame: CGRect) -> SKLabelNode {
        let s = SKLabelNode(text: symbol)
        s.position = CGPoint()
        var sizeConstant = 90.0/844.0
        if preferBiggerSize {
            sizeConstant = 120.0/844.0
        }
        let perfectFitSize = frame.height*sizeConstant
        s.fontSize = perfectFitSize
        s.fontName = "Bungee"
        s.color = self.originalColor
        s.colorBlendFactor = 1.0
        
        if self.shouldAnimateShadows {
            let offset = CGSize(width: s.frame.width/15.0, height: s.frame.height/15.0)
            
            let shadowS = SKLabelNode(text: symbol)
            shadowS.position = CGPoint(x: s.position.x + offset.width,
                                       y: s.position.y - offset.height)
            
            shadowS.fontSize = perfectFitSize
            shadowS.fontName = "Bungee"
            
            shadowS.color = self.shadowColor
            shadowS.colorBlendFactor = 1.0
            
            shadowS.zPosition = -1
            s.addChild(shadowS)
        }
        return s
    }
    
}

