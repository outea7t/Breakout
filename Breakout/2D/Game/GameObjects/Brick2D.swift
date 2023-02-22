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


class Brick2D {
    /// * описывает кастомизацию кирпичика
    /// * strokeTextureForHealth и fillTextureForHealth - опционально, (текстуры для кирпичика)
    /// и обязательные свойства цвета и ширины рамки, и цвета самого кирпичика
    private struct BrickColorSchema {
        var fillTextureForHealth: [Int : SKTexture]?
        var strokeTextureForHealth: [Int: SKTexture]?
        var strokeColor: UIColor
        var fillColor: UIColor
        
        var lineWidth: CGFloat
    }
    private var brickSchemas = [BrickColorSchema]()
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
        self.setBrickColorSchemas()
        
        self.brick.name = "brick"
        self.brick.lineWidth = 5
        

        self.setColorsForBrick()
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
        let schema = self.brickSchemas[0]
        
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
        
        var fillSchema = [Int: SKTexture]()
        // 1
        let _1BrickImage = UIImage.gradientImage(with: self.brick.frame,
                                                 startPoint: CGPoint(x: 0.5, y: 0.0),
                                                 endPoint: CGPoint(x: 0.5, y: 1.0),
                                                 colors: [#colorLiteral(red: 0.946, green: 0.398, blue: 0.398, alpha: 1).cgColor, #colorLiteral(red: 0.416, green: 0.051, blue: 0.639, alpha: 1).cgColor])
        
        
        if let _1BrickImage = _1BrickImage {
            let i1 = UIImage(named: "Brick1-1")!
            let texture = SKTexture(image: i1)
            fillSchema[0] = texture
        
        }
        // 2
        let _2BrickImage = UIImage.gradientImage(with: self.brick.frame,
                                                 startPoint: CGPoint(x: 0.5, y: 0.0),
                                                 endPoint: CGPoint(x: 0.5, y: 1.0),
                                                 colors: [#colorLiteral(red: 0.4156862745, green: 0.05098039216, blue: 0.6392156863, alpha: 1).cgColor, #colorLiteral(red: 0.4392156863, green: 0.02352941176, blue: 0.5882352941, alpha: 1).cgColor])
        
        
        if let _2BrickImage = _2BrickImage {
            let i1 = UIImage(named: "Brick2-1")!
            let texture = SKTexture(image: i1)
            fillSchema[1] = texture
        
        }
        
        // 3
        let _3BrickImage = UIImage.gradientImage(with: self.brick.frame,
                                                 startPoint: CGPoint(x: 0.5, y: 0.0),
                                                 endPoint: CGPoint(x: 0.5, y: 1.0),
                                                 colors: [#colorLiteral(red: 0.4392156863, green: 0.02352941176, blue: 0.5882352941, alpha: 1).cgColor, #colorLiteral(red: 0.2078431373, green: 0.007843137255, blue: 0.6392156863, alpha: 1).cgColor])
        
        
        if let _3BrickImage = _3BrickImage {
            let i1 = UIImage(named: "Brick3-1")!
            let texture = SKTexture(image: i1)
            fillSchema[2] = texture
        
        }
        
        // 4
        let _4BrickImage = UIImage.gradientImage(with: self.brick.frame,
                                                 startPoint: CGPoint(x: 0.5, y: 0.0),
                                                 endPoint: CGPoint(x: 0.5, y: 1.0),
                                                 colors: [#colorLiteral(red: 0.2078431373, green: 0.007843137255, blue: 0.6392156863, alpha: 1).cgColor, #colorLiteral(red: 0.1647058824, green: 0.01960784314, blue: 0.5764705882, alpha: 1).cgColor])
        
        
        if let _4BrickImage = _4BrickImage {
            let i1 = UIImage(named: "Brick4-1")!
            let texture = SKTexture(image: i1)
            fillSchema[3] = texture
        
        }
        
        // 5
        let _5BrickImage = UIImage.gradientImage(with: self.brick.frame,
                                                 startPoint: CGPoint(x: 0.5, y: 0.0),
                                                 endPoint: CGPoint(x: 0.5, y: 1.0),
                                                 colors: [#colorLiteral(red: 0.1647058824, green: 0.01960784314, blue: 0.5764705882, alpha: 1).cgColor, #colorLiteral(red: 0.1647058824, green: 0.01960784314, blue: 0.5764705882, alpha: 1).cgColor])
        
        
        if let _5BrickImage = _5BrickImage {
            let i1 = UIImage(named: "Brick5-1")!
            let texture = SKTexture(image: i1)
            fillSchema[4] = texture
        
        }
        
        let brickColorSchema = BrickColorSchema(fillTextureForHealth: fillSchema,
                                                strokeColor: strokeColor,
                                                fillColor: fillColor,
                                                lineWidth: 5)
        
        self.brickSchemas.append(brickColorSchema)
        
        
    }
}
