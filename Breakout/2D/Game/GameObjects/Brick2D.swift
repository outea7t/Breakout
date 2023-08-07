//
//  Brick.swift
//  Breakout
//
//  Created by Out East on 22.07.2022.
//

/*
 
 
 
        убери вычисление размеров тут или в файле level.swift
 
 
 */
import Foundation
import SpriteKit
import UIKit

struct LevelColorScheme {
    var numberOfBrickRowsTexture: Int
    
    var bricksColorSchema: BrickColorScheme
    var starFillColor: UIColor
    var backgroundColor: UIColor
    var livesLabelColor: UIColor
    var pauseButtonColor: UIColor
    var textColor: UIColor
}
/// * описывает кастомизацию кирпичика
/// * strokeTextureForHealth и fillTextureForHealth - опционально, (текстуры для кирпичика)
/// и обязательные свойства цвета и ширины рамки, и цвета самого кирпичика
struct BrickColorScheme {
    var fillTextureForHealth: [Int : SKTexture]?
    var strokeTextureForHealth: [Int: SKTexture]?
    var strokeColor: UIColor
    var fillColor: UIColor
    
    var lineWidth: CGFloat
}
class Brick2D {
    
    private static var levelColorSchemes = [LevelColorScheme]()
    public static var currentLevelColorScheme: LevelColorScheme {
        get {
            return levelColorSchemes[UserCustomization._2DlevelColorSchemeIndex]
        }
    }
    private var brickSchemes = [BrickColorScheme]()
    // битовые маски различных объектов
    private let ballMask: UInt32    = 0b1 << 0 // 1
    private let paddleMask: UInt32  = 0b1 << 1 // 2
    private let brickMask: UInt32   = 0b1 << 2 // 4
    private let bottomMask: UInt32  = 0b1 << 3 // 8
    
    /// node, которая является представлением кирпичика
    let brick: SKShapeNode
    
    /// текстовое отображение здоровья на кирпичике
    private let healthLabel: SKLabelNode
    /// твердый ли кирпичик
    private let isSolid: Bool
    /// ряд, в котором расположен кирпичик (для цвета)
    private let row: Int
    /// внутреннее отображение здоровья
    var health: UInt {
        willSet {
            healthLabel.text = "\(newValue)"
        }
    }
    
    
    var isDestroyed: Bool
    
    init(health: UInt,
         isSolid: Bool,
         frame: CGRect,
         rows: UInt,
         cols: UInt,
         row: UInt
    ) {
        
        // начало инициализатора
        self.health = health
        self.isSolid = isSolid
        self.healthLabel = SKLabelNode(text: "\(health)")
        self.healthLabel.name = "healthLabel"
        self.isDestroyed = false
        self.row = Int(row)
        // настраиваем тело кирпичика и рисуем его здоровье: если он разрушаемый
        let size = CGSize(width: frame.width/CGFloat(cols),
                          height: frame.height/CGFloat(2*rows))
        
        self.brick = SKShapeNode(rectOf: size, cornerRadius: 20)
        // настраиваем цветовые схемы кирпичиков
        if UserCustomization._2DbuyedLevelColorSchemeIndexes.isEmpty {
            self.setBrickColorSchemas()
            self.setColorsForBrick()
        }
        
        self.brick.name = "brick"
        self.brick.lineWidth = 5
        
        
        
        // физика (у всех одинакова)
        self.brick.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.brick.physicsBody?.allowsRotation = false
        self.brick.physicsBody?.friction = 0.0
        self.brick.physicsBody?.linearDamping = 0.0
        self.brick.physicsBody?.restitution = 1.0
        self.brick.physicsBody?.isDynamic = false
        // столкновения
        self.brick.physicsBody?.categoryBitMask = self.brickMask
        self.brick.physicsBody?.collisionBitMask = self.ballMask
        
        if isSolid {
            self.health = 1
        }
        if health <= 0 {
            self.isDestroyed = true
        }
        
        
    }
    func setColorsForBrick() {
        // КАСТОМ
        // в дальнейшем можно будет легко внедрять новые
        let schema = self.brickSchemes[0]
        
        self.brick.fillColor = schema.fillColor
        self.brick.strokeColor = schema.strokeColor
        self.brick.lineWidth = schema.lineWidth
        
        if let fillTextureForHealth = schema.fillTextureForHealth {
            if let fillTexture = fillTextureForHealth[self.row] {
                self.brick.fillTexture = fillTexture
            }
        }
        
        if let strokeTextureForHealth = schema.strokeTextureForHealth {
            if let strokeTexture = strokeTextureForHealth[Int(self.health)] {
                self.brick.strokeTexture = strokeTexture
            }
        }
    }
    // добавляем кирпичик на сцену
    func add(to scene: SKNode, in position: CGPoint) {
        // тело кирпичика
        self.brick.position = position
        if self.health > 0 {
            scene.addChild(self.brick)
        }
        // информация о здоровье
        if !isSolid {
            self.brick.addChild(self.healthLabel)
            self.healthLabel.position = CGPoint(x: 0, y: 0 - self.healthLabel.frame.size.height/2.0)
            self.healthLabel.zPosition = 1
            self.healthLabel.fontSize = 25
            self.healthLabel.fontColor = .white
            
            self.healthLabel.fontName = "Avenir Next Heavy"
        }
    }
    // сталкиваемся с мячом
    func collision() {
        // если здоровье больше 1 то уменьшаем его, иначе уничтожаем кирпичик
        self.health -= 1
        if health <= 0 {
            self.isDestroyed = true
            // сначала убираем текст с кирпичика
            self.brick.removeAllChildren()
            // потом запускаем анимацию уничтожения кирпичика, по окончанию которой мы удаляем его
            self.brick.run(SKAction.group([
                SKAction.scale(by: 0, duration: 0.2),
                SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent()
                ])
            ]))
            
        }
    }
    
    private func setBrickColorSchemas() {
        let strokeColor = #colorLiteral(red: 0.03933082521, green: 0.03008767031, blue: 0.2666499615, alpha: 1)
        let fillColor = UIColor.white
        
        // 1
        var fillSchema = [Int: SKTexture]()
        for i in 1..<2 {
            for j in 1...5 {
                let image = UIImage(named: "BrickStart-\(j)")!
                let texture = SKTexture(image: image)
                fillSchema[j-1] = texture
            }
        }
        
        let brickColorScheme = BrickColorScheme(fillTextureForHealth: fillSchema,
                                                strokeColor: strokeColor,
                                                fillColor: fillColor,
                                                lineWidth: 5)
        
        self.brickSchemes.append(brickColorScheme)
    }
    
    static func initializeLevelColorSchemes() {
        for i in 0..<UserCustomization._2DmaxLevelColorSchemeIndex {
            let numberOfRows = 1
            let backgroundImage = UIImage(named: "BricksBackground-\(i)")
            let starFillColor = UIColor(named: "Star-\(i)")
            let livesLabelFillColor = UIColor(named: "Lives-\(i)")
            var textColor = UIColor(named: "TextColor-\(i)")
            var backgroundColor = UIColor(named: "Background-\(i)")
            
            var strokeImages = [Int: SKTexture]()
            var brickImages = [Int: SKTexture]()
            
            for j in 1...numberOfRows {
                let strokeImage = UIImage(named: "BrickStroke\(j)-\(i)")
                let brickFillImage = UIImage(named: "Brick\(j)-\(i)")
                
                if let strokeImage = strokeImage, let brickFillImage = brickFillImage {
                    let strokeTexture = SKTexture(image: strokeImage)
                    let brickFillImage = SKTexture(image: brickFillImage)
                    
                    strokeImages[j] = strokeTexture
                    brickImages[j] = brickFillImage
                }
            }
            
            let brickColorScheme = BrickColorScheme(fillTextureForHealth: brickImages,
                                                    strokeTextureForHealth: strokeImages,
                                                    strokeColor: .white,
                                                    fillColor: .white,
                                                    lineWidth: 7)
            
            if let starFillColor = starFillColor,
               let livesLabelFillColor = livesLabelFillColor,
               let textColor = textColor,
               let backgroundColor = backgroundColor
            {
                let scheme = LevelColorScheme(numberOfBrickRowsTexture: numberOfRows,
                                              bricksColorSchema: brickColorScheme,
                                              starFillColor: starFillColor,
                                              backgroundColor: backgroundColor,
                                              livesLabelColor: livesLabelFillColor,
                                              pauseButtonColor: starFillColor,
                                              textColor: textColor)
                
                self.levelColorSchemes.append(scheme)
            }
            
        }
    }
    // эту функцию потом нужно будет использовать для всех кирпичиков
    func setLevelColorScheme() {
        print("entered-1")
        guard !UserCustomization._2DbuyedLevelColorSchemeIndexes.isEmpty && UserCustomization._2DlevelColorSchemeIndex < Brick2D.levelColorSchemes.count else {
            return
        }
        let scheme = Brick2D.levelColorSchemes[UserCustomization._2DlevelColorSchemeIndex]
        self.brick.fillColor = scheme.bricksColorSchema.fillColor
        self.brick.strokeColor = scheme.bricksColorSchema.strokeColor
        self.brick.lineWidth = scheme.bricksColorSchema.lineWidth
        
        self.healthLabel.color = scheme.textColor
        self.healthLabel.colorBlendFactor = 1.0
        
        if let fillTextureForHealth = scheme.bricksColorSchema.fillTextureForHealth {
            if scheme.numberOfBrickRowsTexture == 1, let fillTexture = scheme.bricksColorSchema.fillTextureForHealth?[1] {
                self.brick.fillTexture = fillTexture
            }
            else {
                if let fillTexture = fillTextureForHealth[self.row] {
                    self.brick.fillTexture = fillTexture
                }
            }
        }
        
        if let strokeTextureForHealth = scheme.bricksColorSchema.strokeTextureForHealth {
            if scheme.numberOfBrickRowsTexture == 1, let strokeTexture = scheme.bricksColorSchema.strokeTextureForHealth?[1] {
                self.brick.strokeTexture = strokeTexture
            }
            if let strokeTexture = strokeTextureForHealth[Int(self.health)] {
                self.brick.strokeTexture = strokeTexture
            }
        }
    }
}
