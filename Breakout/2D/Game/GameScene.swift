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
    
    // битовые маски различных объектов
    private let ballMask: UInt32           = 0b1 << 0 // 1
    private let paddleMask: UInt32         = 0b1 << 1 // 2
    private let brickMask: UInt32          = 0b1 << 2 // 4
    private let bottomMask: UInt32         = 0b1 << 3 // 8
    private let trajectoryBallMask: UInt32 = 0b1 << 4 // 16
    private let frameMask: UInt32          = 0b1 << 5 // 32
    private let bonusMask: UInt32          = 0b1 << 6 // 64
    
    // для логики взаимодействия с ракеткой
    private var firstTouchPos = CGPoint()
    private var lastTouchPos = CGPoint()
    // логика игры
    /// количество жизней
    var lives = 3 {
        willSet {
            livesLable.text = "Lives: \(newValue)"
        }
    }
    private let livesLable = SKLabelNode(text: "Lives: 3")
    private var bottom: SKShapeNode!
    /// для контроля количества частиц
    private var lastTime = 0.0
    /// массив с бонусами
    private var bonuses = [Bonus2D]()
    // переменные для осуществления эффектов бонуса
    
    /// множитель скорости для ракетки
    private var paddleSpeedMult = 1.0
    /// замедлена ли ракетка
    private var isPaddleSlowed = false
    /// длительность эффекта замедленной ракетки
    private var paddleSlowedDuration = 10.0
    /// ускорен ли мяч
    private var isBallSpeeded = false
    /// длительность эффекта ускорения для мяча
    private var ballSpeededDuration = 10.0
    /// длительность "перевернутости" рамки с игрой
    private var rotationDuration = 10.0
    /// перевернута ли рамка с игрой
    private var isRotated = false
    
    /// для паузы
    /// создаем дополнительный слой со всеми игровыми объектам
    private let gameNode = SKSpriteNode(color: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0), size: CGSize())
    /// логическую переменную для остановки процессов обновления
    private var isOnPause = false
    /// отображение звезд, которые игрок получил за уровень
    private var stars: Stars2D?
    /// количество очков, которое заработал пользователь
    var score: CGFloat = 0
    /// количество потерянных жизней
    var losedLives: Int = 0
    /// количество звезд
    var numberOfStars: Int {
        get {
            if let stars = self.stars?.numberOfStars {
                return stars
            }
            return 3
        }
    }
    /// В первый ли раз за прохождение уровня запущен мяч
    /// нужна для того, чтобы в правильный момент начать отсчитывать звезды
    private var isFirstBallLaunch = true
    
    // для логики звуков
    private let ballBrickBumpAudioNode = SKAudioNode(fileNamed: SoundNames.brickEverythingBump.rawValue)
    private let ballPaddleBumpAudioNode = SKAudioNode(fileNamed: SoundNames.ballPaddleBump.rawValue)
    private let bonusActivationAudioNode = SKAudioNode(fileNamed: SoundNames.bonusActivation.rawValue)
    private let loseGameResultAudioNode = SKAudioNode(fileNamed: SoundNames.loseResult.rawValue)
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
        self.ball = Ball2D(frame: self.frame.size)
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
 
        self.gameNode.position = CGPoint(x: 0.0, y: 0.0)
        self.addChild(self.gameNode)
        
        let timings = TimeForStars(_2StarTime: 50, _3StarTime: 50)
        self.stars = Stars2D(timings: timings, frameSize: view.frame.size)
        if let ball = self.ball {
            let ballPosition = CGPoint(x: ball.ball.position.x, y: ball.ball.position.y + ball.ballRadius)
            self.stars?.add(to: self.gameNode, scene: self, positionOfBallAttachedToPaddle: ballPosition)
        }
        
        self.ballBrickBumpAudioNode.autoplayLooped = false
        self.ballPaddleBumpAudioNode.autoplayLooped = false
        self.bonusActivationAudioNode.autoplayLooped = false
        self.loseGameResultAudioNode.autoplayLooped = false
        
        self.addChild(self.ballBrickBumpAudioNode)
        self.addChild(self.ballPaddleBumpAudioNode)
        self.addChild(self.bonusActivationAudioNode)
        self.addChild(self.loseGameResultAudioNode)
        
        self.setParticlesSkin()
        self.setBallSkin()
        self.setPaddleSkin()
    }
    
    func loadLevel() {
        self.currentLevel?.loadLevel(to: self.gameNode, frame: self.frame)
    }
    
    func setParticlesSkin() {
        self.ball?.particle.setParticlesSkin()
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
                self.score += 1
                let firstAction = SKAction.changeVolume(to: UserSettings.soundsVolumeValue, duration: 0)
                let a = SKAction.sequence([
                    firstAction,
                    SKAction.play()
                ])
                self.ballBrickBumpAudioNode.run(a)
                
                HapticManager.collisionVibrate(with: .light, 0.5)
                // если тело А - мяч, работаем с телом В
                if contact.bodyA.categoryBitMask == ballMask {
                    if contact.bodyB.node?.name == "brick" {
                        if let brickNode = contact.bodyB.node {
                            self.currentLevel?.collisionHappened(brickNode: brickNode)
                            let bonusPosition = CGPoint(x: brickNode.position.x,
                                                   y: brickNode.position.y - brickNode.frame.height/2.0)
                            let bonus = Bonus2D(frame: self.frame, position: bonusPosition)
                            if bonus.tryToAdd(to: self.gameNode) {
                                self.bonuses.append(bonus)
                            }
                        }
                    }
                    
                }
                // если тело В - мяч, работаем с телом А
                else {
                    if contact.bodyA.node?.name == "brick" {
                        if let brickNode = contact.bodyA.node {
                            self.currentLevel?.collisionHappened(brickNode: brickNode)
                            let bonusPosition = CGPoint(x: brickNode.position.x,
                                                   y: brickNode.position.y - brickNode.frame.height/2.0)
                            let bonus = Bonus2D(frame: self.frame, position: bonusPosition)
                            if bonus.tryToAdd(to: self.gameNode) {
                                self.bonuses.append(bonus)
                            }
                        }
                    }
                }
            }
            else if collision == self.ballMask | self.bottomMask {
                self.collidedToBottom()
                self.paddle?.reset(frame: self.frame)
                
                if self.lives - 1 > 0 {
                    HapticManager.collisionVibrate(with: .heavy, 1.0)
                    self.losedLives += 1
                }
            }
            else if collision == self.ballMask | self.paddleMask {
                HapticManager.collisionVibrate(with: .light, 0.9)
                let volumeChangeAction = SKAction.changeVolume(to: UserSettings.soundsVolumeValue, duration: 0)
                let sequence = SKAction.sequence([
                    volumeChangeAction,
                    SKAction.play()
                ])
                self.ballPaddleBumpAudioNode.run(sequence)
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
            }
            else if collision == self.ballMask | self.frameMask {
                HapticManager.collisionVibrate(with: .light, 0.7)
            }
            else if collision == self.bonusMask | self.paddleMask {
                self.score += 1
                let volumeChangeAction = SKAction.changeVolume(to: UserSettings.soundsVolumeValue, duration: 0)
                let sequence = SKAction.sequence([
                    volumeChangeAction,
                    SKAction.play()
                ])
                self.bonusActivationAudioNode.run(sequence)
                HapticManager.collisionVibrate(with: .soft, 1.0)
                if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
                    if contact.bodyA.categoryBitMask == self.bonusMask {
                        for (i,bonus) in self.bonuses.enumerated() {
                            if bonus.bonus === nodeA {
                                // логика взаимодействия с бонусом ...
                                self.applyBonusEffectOnGame(type: bonus.type)
                                bonus.remove()
                                self.bonuses.remove(at: i)
                            }
                        }
                        
                    } else {
                        for (i,bonus) in bonuses.enumerated() {
                            if bonus.bonus === nodeB {
                                // логика взаимодействия с бонусом ...
                                self.applyBonusEffectOnGame(type: bonus.type)
                                bonus.remove()
                                self.bonuses.remove(at: i)
                            }
                        }
                    }
                }
            }
            else if collision == self.bonusMask | self.bottomMask {
                if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
                    if contact.bodyA.categoryBitMask == self.bonusMask {
                        for (i,bonus) in self.bonuses.enumerated() {
                            if bonus.bonus === nodeA {
                                // логика взаимодействия с бонусом ...
                                bonus.remove()
                                self.bonuses.remove(at: i)
                            }
                        }
                        
                    } else {
                        for (i,bonus) in bonuses.enumerated() {
                            if bonus.bonus === nodeB {
                                
                                // логика взаимодействия с бонусом ...
                                bonus.remove()
                                self.bonuses.remove(at: i)
                            }
                        }
                    }
                }
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
    private func applyBonusEffectOnGame(type: BonusType2D) {
        switch type {
        case .rotate:
            if !self.isRotated {
                self.isRotated = true
                self.rotateFrame()
            }
        case .decreaseSpeedOfPaddle:
            if !self.isPaddleSlowed {
                self.isPaddleSlowed = true
                self.decreaseSpeedOfPaddle()
            }
        case .increaseBallSpeed:
            if !self.isBallSpeeded {
                self.isBallSpeeded = true
                self.increaseBallSpeed()
            }
        case .addLive:
            
            self.addLive()
        case .maxValue:
            break
        }
    }
    private func rotateFrame() {
        self.view?.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
        self.paddle?.paddle.xScale = 1.5
        self.paddle?.paddle.yScale = 1.5
        let rotate = SKAction.wait(forDuration: self.rotationDuration)
        self.gameNode.run(rotate) {
            self.view?.transform = CGAffineTransform.identity.rotated(by: 0)
            self.paddle?.paddle.xScale = 1.0
            self.paddle?.paddle.yScale = 1.0
            self.isRotated = false
        }
    }
    private func decreaseSpeedOfPaddle() {
        let action = SKAction.wait(forDuration: self.paddleSlowedDuration)
        self.paddleSpeedMult = 0.6
        self.gameNode.run(action) {
            self.paddleSpeedMult = 1.0
            self.isPaddleSlowed = false
        }
    }
    private func increaseBallSpeed() {
        self.ball?.lengthOfBallVelocityConstant *= 1.2
        
        let action = SKAction.wait(forDuration: self.ballSpeededDuration)
        self.gameNode.run(action) {
            
            if let constantLength = self.ball?.constantBallVelocityLength {
                self.ball?.lengthOfBallVelocityConstant = constantLength
            }
            self.isBallSpeeded = false
        }
    }
    private func addLive() {
        // восстанавливаем потерянную жизнь
        self.losedLives = max(0, losedLives-1)
        self.lives += 1
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
        self.losedLives = 0
        self.score = 0
        self.currentLevel?.resetLevel(frame: self.frame, gameNode: self.gameNode)
        // перезагружаем позицию ракетки и мяч
        self.ball?.reset()
        self.paddle?.reset(frame: self.frame)
        // убираем эффекты бонусов
        for bonus in bonuses {
            bonus.bonus.removeFromParent()
        }
        self.paddleSpeedMult = 1.0
        self.paddle?.paddle.xScale = 1.0
        self.paddle?.paddle.yScale = 1.0
        if let ball = self.ball {
            self.ball?.lengthOfBallVelocityConstant = ball.constantBallVelocityLength
        }
        self.view?.transform = CGAffineTransform.identity.rotated(by: 0)
        // снимаем мир с паузы
        self.isOnPause = false
        self.gameNode.isPaused = false
        self.isFirstBallLaunch = true
        self.physicsWorld.speed = 1.0
        self.stars?.clearActions()
    }
    func resetAfterWin() {
        self.ball?.reset()
        self.paddle?.reset(frame: self.frame)
        // убираем эффекты бонусов
        for bonus in bonuses {
            bonus.bonus.removeFromParent()
        }
        self.paddleSpeedMult = 1.0
        self.paddle?.paddle.xScale = 1.0
        self.paddle?.paddle.yScale = 1.0
        if let ball = self.ball {
            self.ball?.lengthOfBallVelocityConstant = ball.constantBallVelocityLength

        }
        self.view?.transform = CGAffineTransform.identity.rotated(by: 0)
        
        self.isFirstBallLaunch = true
        self.stars?.clearActions()
        self.lives+=1
        self.losedLives = 0
        self.score = 0
    }
    // если какая-то из осевых скоростей мяча равна 0, то исправляем это
    override func update(_ currentTime: TimeInterval) {
        if !self.isOnPause {
            if let isAttachedToPaddle = self.ball?.isAttachedToPaddle {
                self.trajectoryLine?.update(isAttachedToPaddle, currentTime, scene: self)
            }
            self.ballUpdate(currentTime)
            self.paddleUpdate(currentTime)
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
                let result = (lastTouchPos.x - firstTouchPos.x) * self.paddleSpeedMult
                
                // двигаем ракетку
                self.paddle?.move(by: result)
                self.firstTouchPos = self.lastTouchPos
            }
            for touch in touches {
                if isAttachedToPaddle {
                    if let ball = self.ball {
                        let location = touch.location(in: self)
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
        guard !self.isOnPause else {
            return
        }
        if let isAttachedToPaddle = self.ball?.isAttachedToPaddle, let isTrajectoryCreated = self.trajectoryLine?.isTrajectoryCreated {
            if isAttachedToPaddle && isTrajectoryCreated {
                self.trajectoryLine?.isTrajectoryCreated = false
                self.ball?.isAttachedToPaddle = false
                if self.isFirstBallLaunch {
                    self.stars?.startActions()
                }
                self.isFirstBallLaunch = false
                for touch in touches {
                    self.touchUp(touch: touch)
                    
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
    /// для логики с траекторией
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
            let volumeChangeAction = SKAction.changeVolume(to: UserSettings.soundsVolumeValue, duration: 0)
            let sequence = SKAction.sequence([
                volumeChangeAction,
                SKAction.play()
            ])
            self.loseGameResultAudioNode.run(sequence)
            DispatchQueue.main.async {
                self.setLose()
            }
        }
    }
    // ограничения для мяча и ракетки
    private func ballUpdate(_ currentTime: TimeInterval) {
        if let paddle = self.paddle?.paddle {
            self.ball?.update(paddle: paddle, currentTime: currentTime, gameNode: self.gameNode)
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
    /// переходим в WinViewController
    private func setWin() {
        self.gameVCDelegate?.moveToWinViewController()
    }
    /// переходим в LoseViewController
    private func setLose() {
        self.gameVCDelegate?.moveToLoseViewController()
    }
}
