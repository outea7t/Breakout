//
//  GameScene.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 30.10.2022.
//

import UIKit
import SceneKit
import ARKit

protocol AREndOfGameHandler {
    func moveToWinViewColtroller()
    func moveToLoseViewController()
}
class ARGameScene: SCNScene {
    // игровая логика
    /// количество жизней у игрока
    var lives = 3 {
        willSet {
            // каждый раз, когда устанавливается новое значение, мы обновляем показатель жизней в игре
            if let geometry = self.livesLabel.geometry as? SCNText {
                geometry.string = "Lives: \(newValue)"
            }
        }
    }
    /// делегат для обращения к контроллеру (чтобы выставлять режим победы и проигрыша)
    var gameVCDelegate: AREndOfGameHandler?
    
    /// надпись с количеством жизней в игре
    var livesLabel = SCNNode()
    /// источники света
    private var light = SCNNode()
    // битовые маски (для некоторой логики столкновений)
    private let paddleBitmask:  Int = 0x1 << 0 // 1
    private let ballBitmask:    Int = 0x1 << 1 // 2
    private let frameBitmask:   Int = 0x1 << 2 // 4
    private let brickBitmask:   Int = 0x1 << 3 // 8
    private let bottomBitMask:  Int = 0x1 << 4 // 16
    
    // для логики паузы - объект, к которому мы будем добавлять все остальное, чтобы одновременно все останавливать
        
    // игровые объекта
    private var ball: Ball3D?
    private var brick: Brick3D?
    private var frame: Frame3D?
    private var paddle: Paddle3D?
    private var particle: Particle3D?
    private var lastTime = TimeInterval()
    private var trajectoryLine: TrajectoryLine3D?
    // текущий уровень
    var currentLevel: Level3D?
    // логика движения ракетки
    /// место, где игрок нажал на экран
    private var startTouchPosition = CGPoint()
    /// место, где игрок перестал нажимать на экран
    private var lastTouchPosition = CGPoint()
    // для логики обнаружения плоскости
    /// нужно ли обнаруживать плоскость
    var wantDetectPlane = true
    /// нужно ли создавать на ней сцену
    var wantSetPosition = true
    /// обнаруженные точки поверхности
    var planeAnchors = [ARPlaneAnchor]()
    /// текущая обнаруженная поверхность
    private var detectedPlaneNode: SCNNode?
    /// текущая позиция обнаруженной поверхности в мировых координатах
    private var planeNodePosition: SCNVector3?
    
    deinit {
        print("ARGameSceneViewController Deinitialization")
    }
    /// удаляем все childNodes со сцены
    func removeAllChildren() {
        self.detectedPlaneNode?.removeFromParentNode()
        self.currentLevel?.removeAllBricksBeforeSettingLevel()
        if let frame = self.frame {
            for node in frame.plate.childNodes {
                node.removeFromParentNode()
            }
        }
        for node in self.rootNode.childNodes {
            node.removeFromParentNode()
        }
        self.currentLevel?.bricks = []
    }
    
    /// устанавливаем кирпичики на plate  и рисуем их
    func loadLevel() {
        if let frame = self.frame {
            self.currentLevel?.loadLevel(to: frame)
        }
    }
    /// обновляем игровые объекты
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.update(time)
        self.paddle?.updateNode()
        // обновляем траекторию для мяча
        if let ball = self.ball, let frame = self.frame {
            self.trajectoryLine?.update(ball.isAttachedToPaddle, time, node: frame.plate)
        }
    }
    /// полльзователь коснулся экрана
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, sceneView: ARSCNView) {
        for touch in touches {
            let location = touch.location(in: sceneView)
            self.startTouchPosition = location
            
            
            if let frame = self.frame, let ball = self.ball {
                let touchLocation = touch.location(in: sceneView)
                let center = sceneView.center
                
                // у игровой рамки вершина находится в центре, а у sceneView.frame - в левом верхнем углу
                // поэтому мы переводим координаты .frame в координаты игровой рамки
                let xPosition = touchLocation.x - center.x
                let yPosition = touchLocation.y - center.y
                
                let percentCoordinates = SCNVector3(xPosition/sceneView.bounds.width,
                                                    0.0,
                                                    yPosition/sceneView.bounds.height)
                
                // переводим эти координаты в логальные для игровой рамки
                let frameTouchLocalCoordinates = SCNVector3(percentCoordinates.x*frame.plateVolume.x,
                                                            0.0,
                                                            percentCoordinates.z*frame.plateVolume.z)
                // считаем для определенной позиции траекторию
                if ball.isAttachedToPaddle {
                    let height = sceneView.bounds.height
                    if height - location.y > 50 {
                        self.trajectoryLine?.touchDown(touchLocation: frameTouchLocalCoordinates, scene: self, ball: ball)
                    }
                    
                }
            }
            let hitlist = sceneView.hitTest(location, options: nil)
            for result in hitlist {
                let resultNode = result.node
                let duration = 0.6
                if resultNode.name == "brick" {
                    let resizeAction = SCNAction.sequence([
                        SCNAction.scale(by: 0.5, duration: duration-0.1),
                        SCNAction.scale(by: 1/0.5, duration: duration-0.1)
                    ])
                    let rotateAction = SCNAction.rotate(by: 2*Double.pi, around: SCNVector3(x: 0, y: 1, z: 0), duration: duration+0.1)
                    
                    
                    let color1 = SCNVector3(x: 48/255, y: 62/255, z: 255/255)
                    let color2 = SCNVector3(x: 133/255, y: 237/255, z: 255/255)
                    let action1 = { (node: SCNNode, time: CGFloat) -> Void in
                        let percentage1 = time / (duration-0.1)
                        let percentage2 = 1 - time / (duration-0.1)
                        node.geometry?.firstMaterial?.diffuse.contents = UIColor.init(red: CGFloat(color1.x)*percentage1 +
                                                                                          CGFloat(color2.x)*percentage2,
                                                                                      green: CGFloat(color1.y)*percentage1 + CGFloat(color2.y)*percentage2,
                                                                                      blue: CGFloat(color1.z)*percentage1 + CGFloat(color2.z)*percentage2,
                                                                                      alpha: 1.0)
                        
                    }
                    
                    let action2 = { (node: SCNNode, time: CGFloat) -> Void in
                        let percentage1 = 1 - time / (duration-0.1)
                        let percentage2 = time / (duration-0.1)
                        node.geometry?.firstMaterial?.diffuse.contents = UIColor.init(red: CGFloat(color1.x)*percentage1 + CGFloat(color2.x)*percentage2,
                                                                                      green: CGFloat(color1.y)*percentage1 + CGFloat(color2.y)*percentage2,
                                                                                      blue: CGFloat(color1.z)*percentage1 + CGFloat(color2.z)*percentage2,
                                                                                      alpha: 1.0)
                    }
                    let customAction1 = SCNAction.customAction(duration: duration-0.1, action: action1)
                    customAction1.timingMode = SCNActionTimingMode.linear
                    
                    let customAction2 = SCNAction.customAction(duration: duration-0.1, action: action2)
                    
                    let colorizeAction = SCNAction.sequence([
                        customAction1,
                        customAction2
                    ])
                    
                    result.node.runAction(SCNAction.group([
                        resizeAction,
                        colorizeAction,
                        rotateAction
                    ]))
                }
            }
        }
    }
    /// пользователь провел пальцем по экрану
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, sceneView: ARSCNView) {
        for touch in touches {
            
            self.lastTouchPosition = touch.location(in: sceneView)
            let result = CGPoint(x: -(self.startTouchPosition.x-lastTouchPosition.x)/2000, y: 0)
            if let ball = self.ball {
                if !ball.isAttachedToPaddle {
                    self.paddle?.move(by: result)
                }
            }
            
            self.startTouchPosition = self.lastTouchPosition
            if let frame = self.frame, let ball = self.ball {
                let touchLocation = touch.location(in: sceneView)
                let center = sceneView.center
                
                // у игровой рамки вершина находится в центре, а у sceneView.frame - в левом верхнем углу
                // поэтому мы переводим координаты .frame в координаты игровой рамки
                let xPosition = touchLocation.x - center.x
                let yPosition = touchLocation.y - center.y
                
                let percentCoordinates = SCNVector3(xPosition/sceneView.bounds.width,
                                                    0.0,
                                                    yPosition/sceneView.bounds.height)
                
                // переводим эти координаты в логальные для игровой рамки
                let frameTouchLocalCoordinates = SCNVector3(percentCoordinates.x*frame.plateVolume.x,
                                                            0.0,
                                                            percentCoordinates.z*frame.plateVolume.z)
                // считаем для определенной позиции траекторию
                if ball.isAttachedToPaddle {
                    let height = sceneView.bounds.height
                    if height - touchLocation.y > height/15 {
                        self.trajectoryLine?.touchDown(touchLocation: frameTouchLocalCoordinates,
                                                       scene: self,
                                                       ball: ball)
                    }
                }
            }
        }
    }
    /// нажатия закончились
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let isAttachedToPaddle = self.ball?.isAttachedToPaddle ?? false
        if isAttachedToPaddle {
            if let direction = self.trajectoryLine?.currentDirection, let isTrajectoryCreated = self.trajectoryLine?.isTrajectoryCreated {
                if isTrajectoryCreated {
                    self.ball?.removedFromPaddle(with: direction)
                    self.trajectoryLine?.isTrajectoryCreated = false
                }
                // убираем нарисованные траектории
                    self.trajectoryLine?.clearTrajectories()
                    self.trajectoryLine?.isFirstTouch = true
            }
        }
    }
    /// функция с обработкой столкновений
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if !self.rootNode.isPaused {
            let nodeA = contact.nodeA.physicsBody?.categoryBitMask ?? 0
            let nodeB = contact.nodeB.physicsBody?.categoryBitMask ?? 0
            let result = nodeB | nodeA
            
            if result == self.brickBitmask | self.ballBitmask {
                if nodeA == self.brickBitmask {
                    self.currentLevel?.collisionHappened(brickNode: contact.nodeA)
                } else {
                    self.currentLevel?.collisionHappened(brickNode: contact.nodeB)
                }
                
                HapticManager.collisionVibrate(with: .light, 0.5)
            } else if result == self.paddleBitmask | self.ballBitmask {
                HapticManager.collisionVibrate(with: .light, 0.9)
                // логика высчитывания угла наклона при столкновении с ракеткой
                if let paddle = self.paddle, let ball = self.ball {
                    let centerOfBoard = paddle.paddle.presentation.position.x
                    let distance = (ball.ball.position.x) - centerOfBoard
                    // насколько будем изменять скорость
                    let percentage = distance / (paddle.paddleVolume.x/2.0)
                    
                    if let oldVelocity = ball.ball.physicsBody?.velocity {
                        // используем магическое число 0.065 (для нормального отталкивания мяча от ракетки) - он будет умножать это число на
                        let ballImpulse = 0.065
                        let v = CGVector(dx: ballImpulse * Double(percentage) * 2.0,
                                         dy: Double(oldVelocity.z))
                        
                        
                        self.ball?.ball.physicsBody?.velocity.x = Float(v.dx)
                        if let currentBallVelocity = self.ball?.ball.physicsBody?.velocity {
                            let simdVelocity = simd_float2(Float(currentBallVelocity.x),
                                                           Float(currentBallVelocity.z))
                            
                            let normalizedVelocity = simd_normalize(simdVelocity)
                            
                            let simdOldVelocity = simd_float2(Float(oldVelocity.x),
                                                              Float(oldVelocity.z))
                            
                            let lengthOfOldVelocity = simd_length(simdOldVelocity)
                            
                            let newBallVelocity = SCNVector3(
                                normalizedVelocity.x * lengthOfOldVelocity * 0.9,
                                0.0,
                                normalizedVelocity.y * lengthOfOldVelocity * 0.9)
                            
                            print(newBallVelocity)
                            self.ball?.ball.physicsBody?.velocity = newBallVelocity
                            self.ball?.ballImpulse = newBallVelocity
                            print(self.ball?.ballImpulse)
                        }
                        
                    }
                }
                
            } else if result == self.ballBitmask | frameBitmask {
                HapticManager.collisionVibrate(with: .light, 0.7)
            } else if result == self.ballBitmask | self.bottomBitMask {
                if self.lives - 1 > 0 {
                    HapticManager.collisionVibrate(with: .heavy, 1.0)
                }
                // столкнулись с нижней стенкой - уменьшаем жизни
                self.ball?.reset()
                self.paddle?.reset()
                
                self.lives -= 1
                // если жизней меньше нуля - мы проиграли
                if lives <= 0 {
                    DispatchQueue.main.sync {
                        // переходы из одного контролера в другой должны выполняться в главном потоке
                        // причем, очень важно - синхронно, чтобы мы не переходили в контроллер проигрыша/ победы по нескольку раз
                        if !self.wantDetectPlane && !self.wantSetPosition {
                            self.setLose()
                        }
                    }
                    
                }
            }
            
            let isAllBricksDeleted = self.currentLevel?.deleteDestroyedBricks() ?? false
            if  isAllBricksDeleted {
                // переходы из одного контролера в другой должны выполняться в главном потоке
                DispatchQueue.main.sync {
                    if !self.wantDetectPlane && !self.wantSetPosition {
                        self.setWin()
                    }
                }
            }
        }
    }
    /// создаем сцену и настраиваем node на ней
    func createScene() {
        self.createLight()
        
        // создание игровой рамки
        let plateVolume = SCNVector3(x: 0.3, y: 0.02, z: 0.5)
        self.frame = Frame3D(plateVolume: plateVolume,
                             frontWallVolume: SCNVector3(x: plateVolume.x, y: 0.05, z: 0.025),
                             leftSideWallVolume: SCNVector3(x: 0.025, y: 0.05, z: plateVolume.z),
                             bottomWallVolume: SCNVector3(x: plateVolume.x, y: 0.05, z: 0.025),
                             rightSideWallVolume: SCNVector3(x: 0.025, y: 0.05, z: plateVolume.z))
        if let planeNodePosition = self.planeNodePosition {
            let framePosition = SCNVector3(x: planeNodePosition.x,
                                           y: planeNodePosition.y + plateVolume.y,
                                           z: planeNodePosition.z)
            self.frame?.add(to: self, in: framePosition)
        }
     
        if let frame = self.frame {
            // создание ракетки
            self.paddle = Paddle3D(frame: frame)
            // создание мяча
            self.ball = Ball3D(radius: 0.02)
        
            
            let ballPosition = SCNVector3(x: 0,
                                          y: 0.025,
                                          z:  frame.plateVolume.z/3)
            self.ball?.add(to: frame.plate, in: ballPosition)
            if let radius = self.ball?.ballRadius {
                self.particle = Particle3D(ballRadius: Float(radius))
            }
            if let ball = self.ball {
                self.trajectoryLine = TrajectoryLine3D(ball: ball, node: frame.plate)
            }
        }
        
        // создание надписи - отображения жизней
        let livesTextNodeGeometry = SCNText(string: "Lives: \(self.lives)", extrusionDepth: 0.0125)
        // настраиваем шрифт
        livesTextNodeGeometry.font = UIFont(name: "Arial Rounded MT Bold", size: 1)
        
        // настраиваем материал
        let livesTextNodeMaterial = SCNMaterial()
//        livesTextNodeMaterial.lightingModel = .physicallyBased
        livesTextNodeMaterial.diffuse.contents = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        livesTextNodeMaterial.specular.contents = #colorLiteral(red: 1, green: 0, blue: 0.8277662396, alpha: 1)
//        livesTextNodeMaterial.metalness.contents = 1.0
//        livesTextNodeMaterial.roughness.contents = 1.0
        
        livesTextNodeGeometry.materials = [livesTextNodeMaterial]
        // с горем пополам настраиваем позицию текста так, чтобы она была сверху слева от передней стенки
        self.livesLabel.geometry = livesTextNodeGeometry
        if let frame = self.frame {
            let livesTextScale = SCNVector3(frame.frontWallVolume.x*0.2,
                                            frame.frontWallVolume.y*0.7,
                                            1)
            self.livesLabel.position = SCNVector3( -frame.frontWallVolume.x/2.0,
                                                     frame.frontWallVolume.y/10.0,
                                                     0)
            self.livesLabel.scale = livesTextScale
            frame.frontWall.addChildNode(self.livesLabel)
        }
        // после всех манипуляций устанавливаем позицию
        self.loadLevel()
    }
    /// функция, которая обнаруживает плоскость
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        if self.wantDetectPlane {
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            
            let plane = SCNPlane(width: width, height: height)
            let planeMaterial = SCNMaterial()
            planeMaterial.lightingModel = .shadowOnly
            plane.materials = [planeMaterial]
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.name = "plane"
            
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            
            planeNode.position = SCNVector3(x, y, z)
            self.detectedPlaneNode = planeNode
            
            node.addChildNode(planeNode)
            // поворачиваем плоскость, потому что она изначально вертикальная
            planeNode.eulerAngles.x = -.pi/2.0
            
            self.wantDetectPlane = false
            self.planeAnchors.append(planeAnchor)
        }
    }
    /// функция, которая обновляет плоскость
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }

        
        let planeNode = self.detectedPlaneNode
        
        guard let plane = planeNode?.geometry as? SCNPlane else {return}
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        planeNode!.position = SCNVector3(x, y, z)
        //  для обновления позиции коробки (если мы добавляем ее не к обнаруженной плоскости, а к rootNode)
        if let planeNodePosition = self.detectedPlaneNode?.worldPosition {
            if self.wantSetPosition && !self.wantDetectPlane {
                self.planeNodePosition = planeNodePosition
                self.createScene()
                self.wantSetPosition = false
            }
        }
        
        if !self.planeAnchors.contains(planeAnchor) {
            self.planeAnchors.append(planeAnchor)
        }
    }
    /// ставит игру на паузу
    func pauseGame() {
        self.rootNode.isPaused = true
        self.physicsWorld.speed = 0
        
    }
    /// убирает игру с паузы
    func unpauseGame() {
        self.rootNode.isPaused = false
        self.physicsWorld.speed = 1
    }
    /// перезагружаем уровень (например, когда мы закончили проходить уровень)
    func resetObjects() {
        if let frame = self.frame {
            self.paddle?.reset()
            self.currentLevel?.resetLevel(frame: frame)
        }
        self.ball?.reset()
    }
    /// перезагружаем игру
    func restartGame() {
        resetObjects()
        self.lives = 3
    }
    /// создаем и добавляем свет
    private func createLight() {
        // создаем свет
        let lightObject = SCNLight()
        // тип света
        lightObject.type = .omni
        lightObject.shadowMode = SCNShadowMode.forward
        lightObject.castsShadow = true
        lightObject.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.85)
        lightObject.color = UIColor.white
        
        lightObject.shadowRadius = 12
        lightObject.shadowBias = 40
        
        lightObject.shadowMapSize = CGSize(width: 2048, height: 2048)
        lightObject.shadowSampleCount = 128
//        lightObject.intensity = 100
        
        print(lightObject.intensity)
        self.light.light = lightObject
        if let planeNodePosition = self.planeNodePosition {
            let lighPosition = SCNVector3(x: planeNodePosition.x,
                                          y: planeNodePosition.y + 1.0,
                                          z: planeNodePosition.z - 0.4)
            self.light.position = lighPosition
        }
        self.light.position = SCNVector3(x: 0.0, y: 1.0, z: -0.4)
        self.rootNode.addChildNode(self.light)
        
    }
    /// обновляем игровые объекты
    private func update(_ currentTime: TimeInterval) {
        // обновляем мяч, ракетку и добавляем частички только если игра не на паузе
        if !self.rootNode.isPaused {
            if let frame = self.frame, let paddle = self.paddle, let ball = self.ball {
                self.ball?.update(paddle: paddle)
                self.paddle?.update(frame: frame, isBallAttachedToPaddle: ball.isAttachedToPaddle)
                
                if currentTime - self.lastTime > 1.0/14.0 {
                    self.particle?.addParticle(to: ball, frame: frame)
                    self.lastTime = currentTime
                }
                
            }
        }
        
    }
    /// переходим в меню победы
    private func setWin() {
        self.resetObjects()
        self.gameVCDelegate?.moveToWinViewColtroller()
    }
    /// переходим в меню поражения
    private func setLose() {
        self.resetObjects()
        self.gameVCDelegate?.moveToLoseViewController()
    }
    /// анимация в конце игры
    private func endAnimation() {
        
    } // Идея - создать анимацию, когда все объекты постепенно проваливаются в небытие
    
}


