//
//  GameScene.swift
//  MyFirstIOSProj
//
//  Created by Out East on 07.07.2022.
//

import SpriteKit
import CoreMedia

protocol EndOfGameHandler {
    func moveToWinViewController()
    func moveToLoseViewController()
}

// мы подписываем нашу сцену под протокол SKPhysicsContactDelegate
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // делегат для обращения к контроллеру из игровой сцены
    var gameVCDelegate: EndOfGameHandler?
    var currentLevel: Level2D?
    
    // игровые объекты
    private var ball: Ball2D?
    // для логики столкновения мяча с ракеткой
    private var ballVelocity = CGVector(dx: 300, dy: 300)
    private var paddle: Paddle2D?
    private var trajectoryLine: TrajectoryLine2D?
    
    
    // косметические эфекты
    private var particle: Particle2D?
    
    // битовые маски различных объектов
    private let ballMask: UInt32           = 0b1 << 0 // 1
    private let paddleMask: UInt32         = 0b1 << 1 // 2
    private let brickMask: UInt32          = 0b1 << 2 // 4
    private let bottomMask: UInt32         = 0b1 << 3 // 8
    private let trajectoryBallMask: UInt32 = 0b1 << 4 // 16
    private let frameMask: UInt32          = 0b1 << 5 // 32
    
    // для логики взаимодействия с ракеткой
    private var firstTouchPos = CGPoint()
    private var lastTouchPos = CGPoint()
    // логика игры
    var lives = 3 {
        willSet {
            livesLable.text = "Lives: \(newValue)"
        }
    }
    private let livesLable = SKLabelNode(text: "Lives: 3")
    private var bottom: SKShapeNode!
    // для контроля количества частиц
    private var lastTime = 0.0
    // для паузы
    // создаем дополнительный слой со всеми игровыми объектам
    private let gameNode = SKSpriteNode(color: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0), size: CGSize())
    // логическую переменную для остановки процессов обновления
    private var isOnPause = false
    
   
    // настраиваем все члены
    override func didMove(to view: SKView) {
        self.backgroundColor = #colorLiteral(red: 0.07905098051, green: 0.1308179498, blue: 0.1934371293, alpha: 1)
        // подписка на делегат
        self.physicsWorld.contactDelegate = self
        // настройки самой сцены
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsBody?.categoryBitMask = self.frameMask
        self.physicsBody?.contactTestBitMask = self.ballMask
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        // трение среды
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.friction = 0.0
        
        // количество жизней
        self.livesLable.fontName = "Bungee"
        self.livesLable.fontSize = 75
        self.livesLable.position = CGPoint(x: self.frame.midX,
                                           y: self.frame.midY - 2.75 * self.livesLable.fontSize)
        
//        self.livesLable.zPosition = 10
        self.livesLable.colorBlendFactor = 1.0
        self.livesLable.color = .red
        
        let effectNode = SKEffectNode()
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10.0])
        effectNode.zPosition = -2
        effectNode.addChild(livesLable)
        self.gameNode.addChild(effectNode)
//        self.gameNode.addChild(self.livesLable)
        
        // настройка дна сцены
        var points = [CGPoint(x: 0.0, y: 0.0), CGPoint(x: self.frame.width, y: 0.0)]
        self.bottom = SKShapeNode(points: &points, count: points.count)
        // физика
        self.bottom?.physicsBody = SKPhysicsBody(edgeFrom: points[0], to: points[1])
        self.bottom?.physicsBody?.allowsRotation = false
        self.bottom?.physicsBody?.friction = 0.0
        self.bottom?.physicsBody?.linearDamping = 0.0
        self.bottom?.physicsBody?.restitution = 1.0
        self.bottom?.physicsBody?.isDynamic = false
        // столкновения
        self.bottom?.physicsBody?.categoryBitMask = self.bottomMask
        self.bottom?.physicsBody?.contactTestBitMask = self.ballMask
        if let bottom = bottom {
            self.gameNode.addChild(bottom)
        }
        
        // настройка мяча
        self.ball = Ball2D(frame: self.frame)
        if let ball = self.ball?.ball {
            self.gameNode.addChild(ball)
        }
        
        // траектория для мяча
        if let ball = self.ball {
            self.trajectoryLine = TrajectoryLine2D(ball: ball, scene: self)
        }
        // настройка ракетки
        self.paddle = Paddle2D(frame: self.frame)
        if let paddle = self.paddle?.paddle {
            self.gameNode.addChild(paddle)
        }
        
        // настройка косметического эффекта ("след от мяча")
        if let ballRadius = self.ball?.ballRadius {
            self.particle = Particle2D(ballRadius: ballRadius)
        }
        
        
        self.gameNode.position = CGPoint(x: 0.0, y: 0.0)
        self.addChild(self.gameNode)
        
        self.setParticlesSkin()
        self.setBallSkin()
        self.setPaddleSkin()
        

        // как перевернуть все объекты
//        self.gameNode.position = CGPoint(x: self.frame.width, y: self.frame.height)
//        self.gameNode.run(SKAction.rotate(byAngle: CGFloat.pi, duration: 0.01))
    }
    func loadLevel() {
        self.currentLevel?.loadLevel(to: self.gameNode, frame: self.frame)
        
    }
    
    func setParticlesSkin() {
        self.particle?.setParticlesSkin()
    }
    func setBallSkin() {
        self.ball?.setBallSkin()
    }
    func setPaddleSkin() {
        self.paddle?.setPaddleSkin()
    }
    // начало контакта
    func didBegin(_ contact: SKPhysicsContact) {
        if !self.isOnPause {
            let collision: UInt32 = (contact.bodyA.categoryBitMask |    contact.bodyB.categoryBitMask)
            
            // если столкнулся мяч с кирпичиком
            if collision == self.ballMask | self.brickMask {
                // если тело А - мяч, работаем с телом В
                if contact.bodyA.categoryBitMask == ballMask {
                    if contact.bodyB.node?.name == "brick" {
                        if let brickNode = contact.bodyB.node {
                            self.currentLevel?.collisionHappened(brickNode: brickNode)
                        }
                    }
                    
                }
                // если тело В - мяч, работаем с телом А
                else {
                    if contact.bodyA.node?.name == "brick" {
                        if let brickNode = contact.bodyA.node {
                            self.currentLevel?.collisionHappened(brickNode: brickNode)
                        }
                    }
                }
                HapticManager.collisionVibrate(with: .light, 0.5)
            } else if collision == self.ballMask | self.bottomMask {
                self.collidedToBottom()
                self.paddle?.reset(frame: self.frame)
                self.paddle?.paddle.position.x = 195
                
                if self.lives - 1 > 0 {
                    HapticManager.collisionVibrate(with: .heavy, 1.0)
                }
            } else if collision == self.ballMask | self.paddleMask {
                HapticManager.collisionVibrate(with: .light, 0.9)
                
                // логика высчитывания угла наклона при столкновении с ракеткой
                if let paddle = self.paddle, let ball = self.ball {
                    let centerOfBoard = paddle.paddle.position.x
                    let distance = (ball.ball.position.x) - centerOfBoard
                    // насколько будем изменять скорость
                    let percentage = distance / (paddle.paddle.frame.size.width/2.0)
                    
                    if let oldVelocity = ball.ball.physicsBody?.velocity {
                        // используем магическое число 300 (для нормального отталкивания мяча от ракетки) - он будет умножать это число на 
                        let v = CGVector(dx: 300 * percentage * 2,
                                         dy: oldVelocity.dy)
                        
                        
                        self.ball?.ball.physicsBody?.velocity.dx = v.dx
                        if let currentBallVelocity = self.ball?.ball.physicsBody?.velocity {
                            let simdVelocity = simd_float2(Float(currentBallVelocity.dx),
                                                           Float(currentBallVelocity.dy))
                            
                            let normalizedVelocity = simd_normalize(simdVelocity)
                            
                            let simdOldVelocity = simd_float2(Float(oldVelocity.dx),
                                                              Float(oldVelocity.dy))
                            
                            let lengthOfOldVelocity = CGFloat(simd_length(simdOldVelocity))
                            
                            let newBallVelocity = CGVector(dx: CGFloat(normalizedVelocity.x) * lengthOfOldVelocity,
                                                           dy: CGFloat(normalizedVelocity.y) * lengthOfOldVelocity)
                            self.ball?.ball.physicsBody?.velocity = newBallVelocity
                            
                        }
                        
                    }
                    
                    
                }
            } else if collision == self.ballMask | self.frameMask {
                HapticManager.collisionVibrate(with: .light, 0.7)
            }
            
            
            if let isAllBricksAreDestroyed = self.currentLevel?.deleteDestroyedBricks() {
                if isAllBricksAreDestroyed {
                    DispatchQueue.main.async {
                        self.setWin()
                    }
                }
            }
        }
        
    }
    
    // взаимодействие с игрой из контроллера
    func pauseGame() {
        if !isOnPause {
            self.isOnPause = true
            self.gameNode.isPaused = true
            self.physicsWorld.speed = 0.0
        }
    }
    func unpauseGame() {
        if self.isOnPause {
            self.isOnPause = false
            self.gameNode.isPaused = false
            self.physicsWorld.speed = 1.0
            // чаще всего, когда мы снимаем игру с паузы, то мы выходим с меню паузы
            // или победы или проигрыша, где пользователь может купить какой-нибудь скин,
            // поэтому обновляем все игровые скины
            self.setBallSkin()
            self.setParticlesSkin()
            self.setPaddleSkin()
        }
    }
    func resetTheGame() {
        self.lives = 3
        self.currentLevel?.resetLevel(frame: self.frame, gameNode: self.gameNode)
        // перезагружаем позицию ракетки и мяч
        self.ball?.reset()
        self.paddle?.reset(frame: self.frame)
        // снимаем мир с паузы
        self.isOnPause = false
        self.gameNode.isPaused = false
        self.physicsWorld.speed = 1.0
    }
    func resetAfterWin() {
        self.ball?.reset()
        self.paddle?.reset(frame: self.frame)
        self.lives+=1
    }
    // если какая-то из осевых скоростей мяча равна 0, то исправляем это
    override func update(_ currentTime: TimeInterval) {
        if !self.isOnPause {
            if let isAttachedToPaddle = self.ball?.isAttachedToPaddle {
                self.trajectoryLine?.update(isAttachedToPaddle, currentTime, scene: self)
            }
            self.ballUpdate(currentTime)
            self.paddleUpdate(currentTime)
            if currentTime - self.lastTime > 1/26 {
                if let isAttachedToPaddle = self.ball?.isAttachedToPaddle {
                    if !isAttachedToPaddle {
                        self.particle?.addParticle(to: self.gameNode, ball: self.ball)
                        self.lastTime = currentTime
                    }
                }
                
            }
        }
    }
    
    // функции которые вызываются от нажатий
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // для логики взаимодействия с ракеткой
        self.firstTouchPos = touches.first?.location(in: self) ?? CGPoint()
        for touch in touches {
            if let ball = self.ball {
                if ball.isAttachedToPaddle {
                    let location = touch.location(in: self)
                    print(location)
                    if location.y > self.frame.height * 0.1 {
                        self.trajectoryLine?.touchDown(touch: touch, scene: self, ball: ball)
                    }
                }
            }
        }
        
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let isAttachedToPaddle = self.ball?.isAttachedToPaddle {
            if !self.isOnPause && !isAttachedToPaddle{
                self.lastTouchPos = touches.first?.location(in: self) ?? CGPoint()
                let result = lastTouchPos.x - firstTouchPos.x
                // двигаем ракетку
                self.paddle?.move(by: result)
                self.firstTouchPos = self.lastTouchPos
            }
            for touch in touches {
                if isAttachedToPaddle {
                    if let ball = self.ball {
                        let location = touch.location(in: self)
                        print(location)
                        if location.y > self.frame.height * 0.1 {
                            self.trajectoryLine?.touchDown(touch: touch, scene: self, ball: ball)
                        }
                    }
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // отвязываем мяч от ракетки
        if !self.isOnPause {
            if let isAttachedToPaddle = self.ball?.isAttachedToPaddle, let isTrajectoryCreated = self.trajectoryLine?.isTrajectoryCreated {
                if isAttachedToPaddle && isTrajectoryCreated {
                    self.trajectoryLine?.isTrajectoryCreated = false
                    self.ball?.isAttachedToPaddle = false
                    
                    for touch in touches {
                        self.touchUp(touch: touch)
                        
                    }
                }
            }
            
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // отвязываем мяч от ракетки
        if !self.isOnPause {
            if let isAttachedToPaddle = self.ball?.isAttachedToPaddle, let isTrajectoryCreated = self.trajectoryLine?.isTrajectoryCreated {
                if isAttachedToPaddle && isTrajectoryCreated {
                    self.trajectoryLine?.isTrajectoryCreated = false
                    self.ball?.isAttachedToPaddle = false
                    // формируем дефолтный импульс (если игрок просто нажал на экран)
                    for touch in touches {
                        self.touchUp(touch: touch)
                        
                    }
                }
            }
            
        }
    }
    private func touchUp(touch: UITouch) {
        self.trajectoryLine?.clearTrajectories()
        if let _ = self.ball {
            if let dir = self.trajectoryLine?.currentDirection {
                var direction = dir
                direction = CGVector(dx: direction.dx*40, dy: direction.dy*40)
                if frame.width > 700 && frame.height > 1000 {
                    direction = CGVector(dx: direction.dx * 30, dy: direction.dy * 30)
                }
                self.ball?.ball.physicsBody?.applyImpulse(direction)
                
                // устанавливаем скорость мяча (для логики столкновений с ракеткой)
                if let velocity = self.ball?.ball.physicsBody?.velocity {
                    self.ballVelocity = CGVector(dx: abs(velocity.dx),
                                                 dy: abs(velocity.dy))
                }
            }
        }
    }
    // логика столкновений
    private func collidedToBottom() {
        self.lives = self.lives - 1
        self.ball?.collidedToBottom()
        self.paddle?.reset(frame: self.frame)
        if self.lives <= 0 {
            DispatchQueue.main.async {
                self.setLose()
            }
        }
    }
    // ограничения для мяча и ракетки
    private func ballUpdate(_ currentTime: TimeInterval) {
        if let paddle = self.paddle?.paddle {
            self.ball?.update(paddle: paddle)
        }
        if let isAttachedToPaddle = self.ball?.isAttachedToPaddle {
            if isAttachedToPaddle {
                self.paddle?.boundToCenter(frame: self.frame)
            }
        }
    }
    private func paddleUpdate(_ currentTime: TimeInterval) {
        self.paddle?.paddleUpdate(frame: self.frame)
        
    }
    
    private func setWin() {
        self.gameVCDelegate?.moveToWinViewController()
    }
    private func setLose() {
        self.gameVCDelegate?.moveToLoseViewController()
    }
}

