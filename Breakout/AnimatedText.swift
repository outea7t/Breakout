//
//  AnimatedText.swift
//  Breakout
//
//  Created by Out East on 31.08.2022.
//
// Класс анимированного текста,
// поддерживающего текстуры для каждой отдельной буквы

import Foundation
import SpriteKit
import UIKit

struct AnimatedText {
    /// отображаемый текст
    private let textOfLabel: String
    /// массив с нодами, каждая из который отражает определенный символ
    var label = [SKLabelNode]()
    /// массив со спрайтами, в случае, если пользователь хочет установить текстуры на буквы
    var sprites = [SKSpriteNode]()
    var shadowColor = UIColor()
    /// множитель расстояния между буквами
    private var spaceConstant: CGFloat = 0.075
    /// изначальный цвет
    private var originalColor: UIColor
    /// для того, чтобы увеличивать шрифт во время увеличения размера viewPort
    private let sizeConstant: CGFloat
    /// нужно ли анимировать тени текста
    private let shouldAnimateShadows: Bool
    /// последний раз, когда текст анимировался в фоновом режиме
    var lastAmbientAnimationTime = TimeInterval()
    
    var currentTime = TimeInterval()
    /// высота слова
    var height: CGFloat {
        get {
            if !self.label.isEmpty {
                return self.label[0].frame.height
            }
            if !self.sprites.isEmpty {
                return self.sprites[0].frame.height
            }
            return 0
        }
    }
    /// длина слова
    var width: CGFloat {
        get {
            var sm: CGFloat = 0
            if !self.label.isEmpty {
                for l in self.label {
                    sm += l.frame.size.width
                    sm += l.frame.size.width * self.spaceConstant
                }
                // отнимаем одну такую константу, потому что для первой буквы мы ее не считаем
                sm -= label[0].frame.size.width * self.spaceConstant
                return sm
            }
            if !self.sprites.isEmpty {
                for s in self.sprites {
                    sm += s.frame.size.width
                    sm += s.frame.size.width * self.spaceConstant
                }
                sm -= self.sprites[0].frame.size.width * self.spaceConstant
                return sm
            }
            return 0
        }
    }
    /// позиция текста (находится в его середине)
    var position: CGPoint {
        get {
            if !self.label.isEmpty {
                if self.label.count % 2 == 0 {
                    let middle: Int = Int(label.count)/2
                    let positionX = (self.label[middle].position.x + self.label[middle-1].position.x)/2.0
                    let positionY = self.label[middle].position.y
                    return CGPoint(x: positionX, y: positionY)
                } else {
                    let middle: Int = Int(label.count)/2
                    let positionX = self.label[middle].position.x
                    let positionY = self.label[middle].position.y
                    return CGPoint(x: positionX, y: positionY)
                }
            }
            if !self.sprites.isEmpty {
                if self.sprites.count % 2 == 0 {
                    let middle: Int = Int(self.sprites.count)/2
                    
                    let offsetX = self.sprites[0].position.x - self.sprites[0].frame.width/2.0
                    let positionX = self.width/2.0 + offsetX
                    let positionY = self.sprites[middle].position.y + self.sprites[middle].frame.height/2.0
                    return CGPoint(x: positionX, y: positionY)
                } else {
                    let middle: Int = Int(self.sprites.count)/2
                    let positionX = self.sprites[middle].position.x
                    let positionY = self.sprites[middle].position.y + self.sprites[middle].frame.height/2.0
                    return CGPoint(x: positionX, y: positionY)
                }
            }
            return CGPoint()
        }
    }
    private var positions = [CGPoint]()
    /// конструктор, который не предусматривает использование текстур
    init(text: String,
         color: UIColor,
         frame: CGRect,
         shouldAnimateShadows: Bool,
         sizeConstant: CGFloat = 80,
         shadowColor: UIColor? = nil
    ) {
        self.shouldAnimateShadows = shouldAnimateShadows
        self.textOfLabel = text
        self.originalColor = color
        self.sizeConstant = sizeConstant
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
    /// конструктор, который предусматривает исопльзование текстур
    init(images: [UIImage], frame: CGRect, color: UIColor, sizeConstant: CGFloat = 80) {
        self.shouldAnimateShadows = false
        self.textOfLabel = ""
        self.originalColor = color
        self.sizeConstant = sizeConstant
        self.shadowColor = .clear
        // настраиваем интерактивную надпись-название игры
        for image in images {
            let sprite = self.initSprite(image, frame: frame)
            self.sprites.append(sprite)
        }
    }
    
    /// анимируем отдульную букву
    mutating func animate(colorToChange: UIColor, letter: SKLabelNode) {
        let animation = createAnimation(colorToChange: colorToChange)
        letter.run(animation)
        // обновляем время для ambient анимации
        self.lastAmbientAnimationTime = self.currentTime
    }
    /// анимируем каждый отдельный спрайт
    mutating func animate(colorToChange: UIColor, sprite: SKSpriteNode) {
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
        }
        
    }
    /// расчитываем позицию текста ниже другого анимированного текста
    mutating func calculatePosition(under animatedLabel: AnimatedText, for frameSize: CGSize) {
        if animatedLabel.sprites.count > 0 {
            var lengthOfWord = 0.0
            let heighOfWord = self.sprites[0].frame.height
            
            for l in self.sprites {
                lengthOfWord += l.frame.width
                lengthOfWord += l.frame.width * self.spaceConstant
            }
            // отнимаем одну такую константу, потому что для первой буквы мы ее не считаем
            // если не отнимать ее, то слово будет не в середине
            lengthOfWord -= animatedLabel.sprites[0].frame.width * self.spaceConstant
            
            let offsetX = (frameSize.width - lengthOfWord)/2.0
            
            let offsetY = animatedLabel.sprites[0].position.y - animatedLabel.sprites[0].frame.height/2.0 - heighOfWord/2.0 - heighOfWord / 3.0
            
            self.calculatePosition(with: offsetX, offsetY: offsetY)
        }
        
        if animatedLabel.label.count > 0 {
            var lengthOfWord = 0.0
            let heighOfWord = self.label[0].frame.height
            
            for l in self.label {
                lengthOfWord += l.frame.width
                lengthOfWord += l.frame.width*self.spaceConstant
            }
            // отнимаем одну такую константу, потому что для первой буквы мы ее не считаем
            // если не отнимать ее, то слово будет не в середине
            lengthOfWord -= animatedLabel.label[0].frame.width * self.spaceConstant
            
            let offsetX = (frameSize.width - lengthOfWord)/2.0
            
            let offsetY = animatedLabel.label[0].position.y - animatedLabel.label[0].frame.height/2.0 - heighOfWord/2.0 - heighOfWord / 3.0
            
            self.calculatePosition(with: offsetX, offsetY: offsetY)
        }
    }
    /// считаем позицию с определенным сдвигом
    private mutating func calculatePosition(with offsetX: CGFloat, offsetY: CGFloat) {
        for (index, letter) in self.label.enumerated() {
            if index == 0 {
                letter.position = CGPoint(x: offsetX + self.label[0].frame.width/2.0, y: offsetY)
            } else {
                letter.position = CGPoint(
                    // чуть больше чем нужно, чтобы буквы были чуть дальше друг от друга в связи с шрифтом Bungee
                    x: self.label[index-1].position.x + letter.frame.width * 0.5 + self.label[index-1].frame.width*0.5 + letter.frame.width * self.spaceConstant,
                    y: offsetY)
            }
        }
        
        for (index, sprite) in self.sprites.enumerated() {
            if index == 0 {
                sprite.position = CGPoint(x: offsetX + self.sprites[0].frame.width/2.0, y: offsetY)
            } else {
                sprite.position = CGPoint(
                    // чуть больше чем нужно, чтобы буквы были чуть дальше друг от друга в связи с шрифтом Bungee
                    x: self.sprites[index-1].position.x + sprite.frame.width * 0.5 + self.sprites[index-1].frame.width*0.5 + sprite.frame.width*self.spaceConstant,
                    y: offsetY)
                self.positions.append(sprite.position)
            }
        }
    }
    /// расчитываем позицию текста (всегда находиться в верхней части экрана и в середине)
    /// offset - множитель, показывающий, насколько низки от верха экрана должен быть расположен текст
    mutating func calculatePosition(for frameSize: CGSize, offsetY: CGFloat) {
        var lengthOfWord = 0.0
        if !self.sprites.isEmpty {
            let heighOfWord = self.sprites[0].frame.height
            
            for l in self.sprites {
                lengthOfWord += l.frame.width
                lengthOfWord += l.frame.width * self.spaceConstant
            }
            // отнимаем одну такую константу, потому что для первой буквы мы ее не считаем
            // если не отнимать ее, то слово будет не в середине
            lengthOfWord -= self.sprites[0].frame.width * self.spaceConstant
            
            let offsetX = (frameSize.width - lengthOfWord)/2.0
            
            let realOffsetY = frameSize.height - heighOfWord*offsetY
            
            
            self.calculatePosition(with: offsetX, offsetY: realOffsetY)
        }
        if !self.label.isEmpty {
            let heighOfWord = self.label[0].frame.height
            
            for l in self.label {
                lengthOfWord += l.frame.width
                lengthOfWord += l.frame.width * self.spaceConstant
            }
            // отнимаем одну такую константу, потому что для первой буквы мы ее не считаем
            // если не отнимать ее, то слово будет не в середине
            lengthOfWord -= self.label[0].frame.width * self.spaceConstant
            let offsetX = (frameSize.width - lengthOfWord)/2.0
            
            
            let realOffsetY = frameSize.height - heighOfWord*offsetY
            self.calculatePosition(with: offsetX, offsetY: realOffsetY)
        }
    }
    /// размещаем анимированный текст в любом месте
    /// Anchor Point строки будет находиться в ее центре
    mutating func calculatePosition(for frameSize: CGSize, in position: CGPoint) {
        let offsetX = (position.x - self.width/2.0)
        let offsetY = position.y
        self.calculatePosition(with: offsetX, offsetY: offsetY)
    }
    mutating func touchDown(touchPosition: CGPoint, color: UIColor = .white) {
        for letter in self.label {
            if letter.contains(touchPosition) && !letter.hasActions() {
                self.animate(colorToChange: color, letter: letter)
            }
        }
        for sprite in sprites {
            if sprite.contains(touchPosition) && !sprite.hasActions() {
                self.animate(colorToChange: color, sprite: sprite)
            }
        }
    }
    mutating func touchProcess(touchPosition: CGPoint, color: UIColor = .white) {
        for letter in self.label {
            if letter.contains(touchPosition) && !letter.hasActions() {
                self.animate(colorToChange: color, letter: letter)
            }
        }
        for sprite in self.sprites {
            if sprite.contains(touchPosition) && !sprite.hasActions() {
                self.animate(colorToChange: color, sprite: sprite)
            }
        }
        
    }
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
        let widthToHeightConstant = image.size.width/image.size.height
        let texture = SKTexture(image: image)
        // подстраиваем размер для каждого размера экрана
        let sizeConstant: CGFloat = self.sizeConstant/844 * frame.height
        let height = sizeConstant*1.2
        let width = height*widthToHeightConstant
        // из-за особенности шрифта Bungee высота всегда больше ширины в 1.2 раза
        let s = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: width,
                                                                           height: height))
        s.colorBlendFactor = 2.0
        s.position = CGPoint()
        // для того, чтобы анимация проигрывалась правильно
        s.anchorPoint = CGPoint(x: s.anchorPoint.x, y: 0.0)
        return s
    }
    /// расчитываем размер буквы
    private func initLetter(_ symbol: String, frame: CGRect) -> SKLabelNode {
        let s = SKLabelNode(text: symbol)
        s.position = CGPoint()
        let sizeConstant = self.sizeConstant/844.0
    
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

