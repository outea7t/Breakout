//
//  ViewController.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 15.08.2022.
//

import UIKit
import SceneKit
import ARKit
import SpriteKit

class ARGameViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var gameSceneView: ARSCNView!
    @IBOutlet weak var starSpriteKitView: SKView!
    weak var gameScene: SCNScene?
    
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
    /// надпись с количеством жизней в игре
    var livesLabel = SCNNode()
    /// источники света
    private var light = SCNNode()
    private let paddleBitmask:      Int = 0x1 << 0 // 1
    private let ballBitmask:        Int = 0x1 << 1 // 2
    private let frameBitmask:       Int = 0x1 << 2 // 4
    private let brickBitmask:       Int = 0x1 << 3 // 8
    private let bottomBitMask:      Int = 0x1 << 4 // 16
    private let trajectoryBallMask: Int = 0x1 << 5 // 32
    private let plateBitmask:       Int = 0x1 << 6 // 64
    private let bonusBitMask:       Int = 0x1 << 7 // 128
    
    // для логики паузы - объект, к которому мы будем добавлять все остальное, чтобы одновременно все останавливать
        
    // игровые объекты
    private var ball: Ball3D?
    private var brick: Brick3D?
    private var frame: Frame3D?
    private var paddle: Paddle3D?
    private var particle: Particle3D?
    private var lastTime = TimeInterval()
    private var trajectoryLine: TrajectoryLine3D?
    
    // текущий уровень
    var currentLevel: Level3D? {
        willSet {
            if let _3StarTime = newValue?._3StarTime, let _2StarTime = newValue?._2StarTime {
                let timings = TimeForStars(_2StarTime: _2StarTime, _3StarTime: _3StarTime)
                self.starSpriteKitScene?.setStarTimings(timings: timings)
            } else {
                let timings = TimeForStars(_2StarTime: 50, _3StarTime: 50)
                self.starSpriteKitScene?.setStarTimings(timings: timings)
            }
        }
    }
    var isPaused = false
    
    // логика движения ракетки
    /// место, где игрок нажал на экран
    private var startTouchPosition = CGPoint()
    /// место, где игрок перестал нажимать на экран
    private var lastTouchPosition = CGPoint()
    
    // логика бонусов
    /// массив с текущими бонусами
    private var bonuses = [Bonus3D]()
    /// множитель скорости для ракетки
    private var paddleSpeedMult = 1.0
    /// замедлена ли ракетка
    private var isPaddleSlowed = false
    /// длительность эффекта замедленной ракетки
    private var paddleSlowedDuration = 10.0
    /// множитель скорости для мяча
    private var ballSpeedMult = 1.3
    /// ускорен ли мяч
    private var isBallSpeeded = false
    /// длительность эффекта ускорения для мяча
    private var ballSpeededDuration = 10.0
    /// длительность "перевернутости" рамки с игрой
    private var rotationDuration = 10.0
    /// перевернута ли рамка с игрой
    private var isRotated = false
    
    // для логики обнаружения плоскости
    /// нужно ли обнаруживать плоскость
    var wantDetectPlane = true
    /// закреплена ли позиция рамки с игрой на плоскости
    var isFramePositionPinned = false
    /// нужно ли создавать на ней сцену
    var wantSetPosition = true
    /// обнаруженные точки поверхности
    var planeAnchors = [ARPlaneAnchor]()
    /// текущая обнаруженная поверхность
    private var detectedPlaneNode: SCNNode?
    /// текущая позиция обнаруженной поверхности в мировых координатах
    private var planeNodePosition: SCNVector3?
    
    weak var starSpriteKitScene: StarScene?
    /// количество очков, которое заработал пользователь
    var score: CGFloat = 0
    /// количество потерянных жизней
    var losedLives: Int = 0
    /// количество звезд
    var numberOfStars: Int {
        get {
            if let stars = self.starSpriteKitScene?.stars?.numberOfStars {
                return stars
            }
            return 3
        }
    }
    /// В первый ли раз за прохождение уровня запущен мяч
    /// нужна для того, чтобы в правильный момент начать отсчитывать звезды
    var isFirstBallLaunch = true
    var levelChoosed: Int = 1 {
        willSet {
            self.currentLevel?.removeAllBricksBeforeSettingLevel()
            self.currentLevel = self.levels[newValue-1]
            self.loadLevel()
        }
    }
    private var levels = [Level3D]()
    /// сигнализирует о том, что пользователь вышел из игры и сессия прервалась
    private var sessionWasInterrupted = false
    /// угол, на который повернута сцена
    private var sceneRotationAngle: CGFloat = 0
    
    deinit {
        print("ARGameViewController Deinitialization")
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
        if let gameScene = self.gameScene {
            for node in gameScene.rootNode.childNodes {
                node.removeFromParentNode()
            }
        }
        self.currentLevel?.bricks = []
    }
    
    /// устанавливаем кирпичики на plate  и рисуем их
    func loadLevel() {
        if let frame = self.frame {
            self.currentLevel?.loadLevel(to: frame)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // настраиваем debug опции
//        self.gameSceneView.debugOptions = [.showFeaturePoints, .showLightExtents, .showWorldOrigin]
        
        // устанавливаем делегат для AR
        self.gameSceneView.delegate = self
        
        // показывать статистику (ФПС И КОЛ-ВО nodes)
//        self.gameSceneView.showsStatistics = true
        self.gameSceneView.allowsCameraControl = false
        self.gameSceneView.autoenablesDefaultLighting = true
        
        // создаем новую сцену
        let scene = SCNScene()
        self.gameScene = scene
        
        scene.rootNode.name = "rootNode"
        scene.physicsWorld.gravity = SCNVector3(0.0, 0.0, 0.0)
        scene.rootNode.physicsBody = SCNPhysicsBody()
        scene.rootNode.physicsBody?.damping = 0.0
        scene.rootNode.physicsBody?.friction = 0.0
        scene.rootNode.physicsBody?.restitution = 1.0
        scene.rootNode.physicsBody?.angularDamping = 0.0
        
        // устанавливаем сцену к view
        self.gameSceneView.scene = scene
        // делегат для работы функций контакта
        self.gameSceneView.scene.physicsWorld.contactDelegate = self
        // устанавливаем предпочтительное количество кадров в секунду у view
        self.gameSceneView.preferredFramesPerSecond = 60
        self.gameSceneView.rendersMotionBlur = true
        
        self.currentLevel?.removeAllBricksBeforeSettingLevel()
        self.currentLevel = self.levels[self.levelChoosed-1]
        
        
//        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationGesture))
        
//        self.view.addGestureRecognizer(rotationGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        
        self.starSpriteKitView.backgroundColor = .clear
        
        let starSpriteKitScene = StarScene(size: self.starSpriteKitView.bounds.size)
        
        self.starSpriteKitView.presentScene(starSpriteKitScene)
        starSpriteKitScene.scaleMode = .fill
        
        starSpriteKitScene.anchorPoint = CGPoint()
        self.starSpriteKitScene = starSpriteKitScene
        
        if let _3StarTime = self.currentLevel?._3StarTime, let _2StarTime = self.currentLevel?._2StarTime {
            let timings = TimeForStars(_2StarTime: _2StarTime, _3StarTime: _3StarTime)
            self.starSpriteKitScene?.updateStarTimings(timings: timings)
        } else {
            let timings = TimeForStars(_2StarTime: 50, _3StarTime: 50)
            self.starSpriteKitScene?.updateStarTimings(timings: timings)
        }
        // пока не добавляю, так как много багов(((((
        self.view.addGestureRecognizer(pinchGestureRecognizer)
        
        let coachingOverlayView = ARCoachingOverlayView()

        coachingOverlayView.session = self.gameSceneView.session
        coachingOverlayView.delegate = self
        coachingOverlayView.goal = .horizontalPlane

        coachingOverlayView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(coachingOverlayView)
        
        NSLayoutConstraint.activate([
            coachingOverlayView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            coachingOverlayView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            coachingOverlayView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            coachingOverlayView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
        ])
    }
    
    @objc func rotationGesture(_ gesture: UIRotationGestureRecognizer) {
        
        // чтобы пользователь не мог обратно перевернуть рамку во время эффекта разворота
        guard let isAttachedToPaddle = self.ball?.isAttachedToPaddle else {
            return
        }
        guard isAttachedToPaddle else {
            return
        }
        switch gesture.state {
        case .began:
            let rotation = gesture.rotation/20
            self.rotateScene(rotation, duration: 0.0001)
        case .changed:
            let rotation = gesture.rotation/20
            self.rotateScene(rotation, duration: 0.0001)
        case .cancelled:
            break
        case .ended:
            break
        case .failed:
            break
        case .possible:
            break
        @unknown default:
            break
        }
    }
    @objc func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
        // смотрим, если пользователь запустил мяч, то он не сможет изменять размер рамки
        guard let isAttachedToPaddle = self.ball?.isAttachedToPaddle else {
            return
        }
        guard isAttachedToPaddle else {
            return
        }
        
        var scale = gesture.scale
        if scale >= 1.5 {
            scale = 1.5
        } else if scale <= 0.5 {
            scale = 0.5
        }
        
        switch gesture.state {
        case .began:
            self.scaleScene(scaleFactor: scale)
        
        case .changed:
            self.scaleScene(scaleFactor: scale)
        break
        case .ended:
        break
        case .cancelled:
        break
        case .failed:
        break
        case .possible:
        break
        @unknown default:
            break
        }
    }
    /// вращаем всю рамку с игрой
    /// нужно, например, для того, чтобы пользователь
    private func rotateScene(_ angle: CGFloat, duration: TimeInterval) {
        guard !self.isRotated && !self.isPaused else {
            return
        }
        guard let frame = self.frame else {
            return
        }
        
        self.sceneRotationAngle += angle
        if abs(self.sceneRotationAngle)/CGFloat.pi * 180 > 360 {
            var sign: CGFloat = 1.0
            if self.sceneRotationAngle.sign == .minus {
                sign = -1.0
            }
            self.sceneRotationAngle -= sign*2*CGFloat.pi
        }
        frame.plate.orientation = SCNQuaternion(0, angle, 0, angle)
        
    }
    
    /// следим, чтобы сцена не "заехала за обнаруженную плоскость" так как иначе она станет прозрачной
    private func moveScene(detectedNodePosition: SCNVector3) {
        guard let frame = self.frame else {
            return
        }
        
        var destinationPlatePosition = frame.plate.position
        destinationPlatePosition.y = detectedNodePosition.y + frame.plateVolume.y*2
        
        let moveAction = SCNAction.move(to: destinationPlatePosition, duration: 0.0001)
        
        frame.plate.runAction(moveAction)
    }
    private func scaleScene(scaleFactor: CGFloat) {
        guard let frame = self.frame else {
            return
        }
        
        let scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        frame.plate.scale = scale
        
        self.trajectoryLine?.frameScale = scaleFactor
        self.ball?.updateBallVelocityLength(scaleFactor: Float(scaleFactor))
        self.updatePhysicsBodyScale(node: frame.plate, scale: scale)
        for child in frame.plate.childNodes {
            self.updatePhysicsBodyScale(node: child, scale: scale)
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.gameSceneView.session.pause()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateConfiguration()
    }
    func updateConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        // создаем конфигурацию сессии
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        
//        configuration.worldAlignment = .camera
        // телефон должен иметь конфигурацию отслеживания мира
        self.gameSceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.gameSceneView.session.pause()
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
            let texture = SKTexture(imageNamed: "ARPlaneTexture.png")
            planeMaterial.diffuse.contents = texture
            planeMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(5, -5, 0)
            planeMaterial.diffuse.wrapS = .repeat
            planeMaterial.diffuse.wrapT = .repeat
            
//            planeMaterial.lightingModel = .shadowOnly
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
        
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
        
//        planeNode!.position = SCNVector3(x, y, z)
        
        //  для обновления позиции коробки (если мы добавляем ее не к обнаруженной плоскости, а к rootNode)
        if let planeNodePosition = self.detectedPlaneNode?.worldPosition {
            if self.wantSetPosition && !self.wantDetectPlane {
                self.planeNodePosition = planeNodePosition
                let waitAction = SCNAction.wait(duration: 3.0)
                self.gameScene?.rootNode.runAction(waitAction) {
                    self.createScene()
                }
//                self.createScene()
                self.wantSetPosition = false
            }
//            self.moveScene(detectedNodePosition: planeNodePosition)
        }
        
        if !self.planeAnchors.contains(planeAnchor) {
            self.planeAnchors.append(planeAnchor)
        }
        
        if !self.isFramePositionPinned {
            // Perform a continuous hit-test using the current frame
            DispatchQueue.main.async { [weak self] in
                guard let sceneView = self?.gameSceneView else {
                    return
                }
                
                let raycast = sceneView.raycastQuery(from: sceneView.center, allowing: .existingPlaneGeometry, alignment: .horizontal)
                guard let raycast = raycast, let plateVolume = self?.frame?.plateVolume, let angle = sceneView.pointOfView?.eulerAngles.y  else {
                    return
                }
                
                let results = sceneView.session.raycast(raycast)
                if let result = results.first {
                    let hitPosition = result.worldTransform.columns.3
                    
                    let desirablePosition = SCNVector3(hitPosition.x, hitPosition.y + plateVolume.y , hitPosition.z)
                    let moveAction = SCNAction.move(to: desirablePosition, duration: 0.25)
                    self?.frame?.plate.runAction(moveAction)
                    
//                    guard let pivot = self?.frame?.plate.pivot else {
//                        return
//                    }
//                    let rotateAction = SCNAction.rotateTo(x: 0, y: CGFloat(angle), z: 0, duration: 0.15)
//                    self?.frame?.plate.runAction(rotateAction)
                }
            }
        }
    }
    /// показывает сообщение об ошибке пользователю
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    /// обновляем игровые объекты
    private func update(_ currentTime: TimeInterval) {
        // обновляем мяч, ракетку и добавляем частички только если игра не на паузе
        guard !self.isPaused else {
            return
        }
        guard let frame = self.frame, let paddle = self.paddle, let ball = self.ball else {
            return
        }
        guard let particlesPerSecond = self.particle?.particlesPerSecond else {
            return
        }
            
        self.ball?.update(paddle: paddle, frame: frame)
        paddle.update(frame: frame, isBallAttachedToPaddle: ball.isAttachedToPaddle)
        
        
        if currentTime - self.lastTime >= particlesPerSecond {
            self.particle?.addParticle(to: ball, frame: frame)
            self.lastTime = currentTime
        }
    }
    /// вызывается, когда сессия прерывается
    func sessionWasInterrupted(_ session: ARSession) {
        self.pauseGame()
        print("interrupted")
        self.gameSceneView.session.pause()
        
        
        self.sessionWasInterrupted = true
        self.performSegue(withIdentifier: "FromARGameToARPause", sender: self)
    }
    
    /// обновляем игровые объекты
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard !self.isPaused else {
            return
        }
        self.update(time)
        self.paddle?.updateNode()
        // обновляем траекторию для мяча
        if let ball = self.ball, let frame = self.frame {
            self.trajectoryLine?.update(ball.isAttachedToPaddle, time, node: frame.plate)
        }
        // уменьшаем интенсивность света, если "вокруг" игрока темно
        if let estimate = self.gameSceneView.session.currentFrame?.lightEstimate {
            self.light.light?.intensity = estimate.ambientIntensity
        }
        
    }
    /// полльзователь коснулся экрана
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard !self.isPaused && touches.count == 1 else {
            return
        }
        guard self.isFramePositionPinned else {
            return
        }
        for touch in touches {
            let location = touch.location(in: self.gameSceneView)
            self.startTouchPosition = location
            
            
            if let frame = self.frame, let ball = self.ball {
                let touchLocation = touch.location(in: self.gameSceneView)
                let center = self.gameSceneView.center
                
                // у игровой рамки вершина находится в центре, а у sceneView.frame - в левом верхнем углу
                // поэтому мы переводим координаты .frame в координаты игровой рамки
                let xPosition = touchLocation.x - center.x
                let yPosition = touchLocation.y - center.y
                
                let percentCoordinates = SCNVector3(xPosition/self.gameSceneView.bounds.width,
                                                    0.0,
                                                    yPosition/self.gameSceneView.bounds.height)
                
                // переводим эти координаты в логальные для игровой рамки
                let frameTouchLocalCoordinates = SCNVector3(percentCoordinates.x*frame.plateVolume.x,
                                                            0.0,
                                                            percentCoordinates.z*frame.plateVolume.z)
                // считаем для определенной позиции траекторию
                if ball.isAttachedToPaddle {
                    let height = self.gameSceneView.bounds.height
                    if height - location.y > 50 {
                        if let gameScene = self.gameScene {
                            self.trajectoryLine?.touchDown(touchLocation: frameTouchLocalCoordinates, scene: gameScene, ball: ball)
                        }
                    }
                    
                }
            }
            
        }
        
    }
    /// пользователь провел пальцем по экрану
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.isPaused else {
            return
        }
        guard touches.count == 1 else {
            return
        }
        guard self.isFramePositionPinned else {
            return
        }
        for touch in touches {
            self.lastTouchPosition = touch.location(in: self.gameSceneView)
            let result = CGPoint(x: -(self.startTouchPosition.x-lastTouchPosition.x)/2000, y: 0)
            if let ball = self.ball {
                if !ball.isAttachedToPaddle {
                    self.paddle?.move(by: result)
                }
            }
            
            self.startTouchPosition = self.lastTouchPosition
            if let frame = self.frame, let ball = self.ball {
                let touchLocation = touch.location(in: self.gameSceneView)
                let center = self.gameSceneView.center
                
                // у игровой рамки вершина находится в центре, а у sceneView.frame - в левом верхнем углу
                // поэтому мы переводим координаты .frame в координаты игровой рамки
                let xPosition = touchLocation.x - center.x
                let yPosition = touchLocation.y - center.y
                
                let percentCoordinates = SCNVector3(xPosition/self.gameSceneView.bounds.width,
                                                    0.0,
                                                    yPosition/self.gameSceneView.bounds.height)
                
                // переводим эти координаты в логальные для игровой рамки
                let frameTouchLocalCoordinates = SCNVector3(percentCoordinates.x*frame.plateVolume.x,
                                                            0.0,
                                                            percentCoordinates.z*frame.plateVolume.z)
                // считаем для определенной позиции траекторию
                if ball.isAttachedToPaddle {
                    let height = self.gameSceneView.bounds.height
                    if height - touchLocation.y > height/15 {
                        if let gameScene = self.gameScene {
                            self.trajectoryLine?.touchDown(touchLocation: frameTouchLocalCoordinates,
                                                           scene: gameScene,
                                                           ball: ball)
                        }
                    }
                }
            }
        }
        
    }
    /// нажатия закончились
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.isPaused else {
            return
        }
        guard touches.count == 1 else {
            return
        }
        
        if !self.wantDetectPlane && !self.isFramePositionPinned {
            self.isFramePositionPinned = true
            let newPlaneMaterial = SCNMaterial()
            newPlaneMaterial.lightingModel = .shadowOnly
            self.detectedPlaneNode?.geometry?.materials = [newPlaneMaterial]
            
            HapticManager.collisionVibrate(with: .medium, 1.0)
            return
        }
        let isAttachedToPaddle = self.ball?.isAttachedToPaddle ?? false
        if isAttachedToPaddle {
            if let direction = self.trajectoryLine?.currentDirection, let isTrajectoryCreated = self.trajectoryLine?.isTrajectoryCreated {
                if isTrajectoryCreated {
                    if self.isFirstBallLaunch {
                        self.isFirstBallLaunch = false
                        self.starSpriteKitScene?.stars?.startActions()
                    }
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
        guard !self.isPaused else {
            return
        }
        let nodeA = contact.nodeA.physicsBody?.categoryBitMask ?? 0
        let nodeB = contact.nodeB.physicsBody?.categoryBitMask ?? 0
        let result = nodeB | nodeA
        
        if result == self.brickBitmask | self.ballBitmask {
            self.ball?.playCollisionToBrickSound()
            if nodeA == self.brickBitmask {
                self.score += 1.5
                self.currentLevel?.collisionHappened(brickNode: contact.nodeA)
                let brickNode = contact.nodeA
                
                let bonusPosition = SCNVector3(x: brickNode.position.x,
                                               y: 0.03,
                                               z: brickNode.position.z + 0.05)
                if let frame = self.frame {
                    let bonus = Bonus3D(frame: frame, position: bonusPosition)
                    if bonus.tryToAdd(to: frame) {
                        self.bonuses.append(bonus)
                    }
                }
            } else {
                self.score += 1.5
                self.currentLevel?.collisionHappened(brickNode: contact.nodeB)
                let brickNode = contact.nodeB
                
                let bonusPosition = SCNVector3(x: brickNode.position.x,
                                               y: 0.03,
                                               z: brickNode.position.z + 0.05)
                if let frame = self.frame {
                    let bonus = Bonus3D(frame: frame, position: bonusPosition)
                    if bonus.tryToAdd(to: frame) {
                        self.bonuses.append(bonus)
                    }
                }
            }
            
            HapticManager.collisionVibrate(with: .light, 0.5)
        }
        else if result == self.paddleBitmask | self.ballBitmask {
            self.ball?.playCollisionToPaddleSound()
            HapticManager.collisionVibrate(with: .light, 0.9)
            // логика высчитывания угла наклона при столкновении с ракеткой
            if let paddle = self.paddle, let ball = self.ball {
                let centerOfBoard = paddle.paddle.position.x
                
                let presentationOfBall = ball.ball.presentation.position.x
                let distance = (presentationOfBall - centerOfBoard)
                // насколько будем изменять скорость
                
                // корректируем процент, на который будем изменять скорость, чтобы он не выходил за 0.5
                // в противном случае мяч будет слишком сильно уходить влево или вправо
                var percentage = (distance / (paddle.paddleVolume.x/2.0))
                if abs(percentage) > 0.5 {
                    percentage = 0.5 * (abs(percentage)/percentage)
                }
//                let percentageBefore = percentage
//                percentage -= 2*Float(self.sceneRotationAngle/(CGFloat.pi * 1.0))
//                print(percentageBefore, percentage)
                if let oldVelocity = ball.ball.physicsBody?.velocity {
                    // используем магическое число 0.065 (для нормального отталкивания мяча от ракетки)
                    let ballImpulse = 0.065*4
                    let v = CGVector(dx: ballImpulse * Double(percentage) * 2.0,
                                     dy: Double(oldVelocity.z))
                    
                    self.ball?.ball.physicsBody?.velocity.x = Float(v.dx)
                    self.ball?.ball.presentation.physicsBody?.velocity.x = Float(v.dx)
                    
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
                        
                        self.ball?.ball.physicsBody?.velocity = newBallVelocity
                    }
                    
                }
            }
            
        }
        else if result == self.ballBitmask | frameBitmask {
            HapticManager.collisionVibrate(with: .light, 0.7)
        }
        else if result == self.ballBitmask | self.bottomBitMask {
            if self.lives - 1 > 0 {
                HapticManager.collisionVibrate(with: .heavy, 1.0)
            }
            // столкнулись с нижней стенкой - уменьшаем жизни
            self.ball?.reset()
            self.paddle?.reset()
            self.losedLives += 1
            self.lives -= 1
            // если жизней меньше нуля - мы проиграли
            if lives <= 0 {
                // переходы из одного контролера в другой должны выполняться в главном потоке
                // причем, очень важно - синхронно, чтобы мы не переходили в контроллер проигрыша/ победы по нескольку раз
                HapticManager.loseHaptic()
                if !self.wantDetectPlane && !self.wantSetPosition {
                    self.resetObjects()
                    self.pauseGame()
                    
                    self.gameSceneView.session.pause()
                    DispatchQueue.main.async { [weak self] in
                        self?.performSegue(withIdentifier: "FromARGameToARLose", sender: self)
                    }
                }
            }
        }
        else if result == self.bonusBitMask | self.paddleBitmask {
            
            if nodeA == bonusBitMask {
                let bonusNode = contact.nodeA
                for (i,bonus) in self.bonuses.enumerated() {
                    if bonus.bonus === bonusNode {
                        // логика взаимодействия с бонусом ...
                        bonus.playBonusActivationSound()
                        self.applyBonusEffectOnGame(type: bonus.type)
                        bonus.remove()
                        self.bonuses.remove(at: i)
                    }
                }
            } else {
                let bonusNode = contact.nodeB
                for (i,bonus) in self.bonuses.enumerated() {
                    if bonus.bonus === bonusNode {
                        // логика взаимодействия с бонусом ...
                        bonus.playBonusActivationSound()
                        self.applyBonusEffectOnGame(type: bonus.type)
                        bonus.remove()
                        self.bonuses.remove(at: i)
                    }
                }
            }
        }
        else if result == self.bonusBitMask | self.bottomBitMask {
            if nodeA == self.bonusBitMask {
                let bonuseNode = contact.nodeA
                for (i,bonus) in self.bonuses.enumerated() {
                    if bonus.bonus === bonuseNode {
                        bonus.remove()
                        self.bonuses.remove(at: i)
                    }
                }
            } else {
                let bonuseNode = contact.nodeB
                for (i,bonus) in self.bonuses.enumerated() {
                    if bonus.bonus === bonuseNode {
                        bonus.remove()
                        self.bonuses.remove(at: i)
                    }
                }
            }
        }
        let isAllBricksDeleted = self.currentLevel?.deleteDestroyedBricks() ?? false
        if  isAllBricksDeleted {
            // переходы из одного контролера в другой должны выполняться в главном потоке
            HapticManager.winHaptic()
            if !self.wantDetectPlane && !self.wantSetPosition {
                self.resetObjects()
                self.pauseGame()
//                    HapticManager.winHaptic()
                self.gameSceneView.session.pause()
                
                DispatchQueue.main.async { [weak self] in
                    self?.performSegue(withIdentifier: "FromARGameToARWin", sender: self)
                }
            }
            
        }
    }
    
    private func applyBonusEffectOnGame(type: BonusType3D) {
        self.score += 1.5
        switch type {
        case .rotate:
            if !self.isRotated {
                self.rotateFrame()
                self.isRotated = true
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
        if let plate = self.frame?.plate {
            
            let waitAction = SCNAction.wait(duration: self.rotationDuration)
            self.rotateScene(CGFloat.pi, duration: 0.5)
            plate.runAction(waitAction) {
                self.rotateScene(CGFloat.pi, duration: 0.5)
                self.isRotated = false
            }
        }
    }
    private func decreaseSpeedOfPaddle() {
        if let plate = self.frame?.plate {
            self.paddleSpeedMult = 0.6
            
            let waitAction = SCNAction.wait(duration: self.paddleSlowedDuration)
            plate.runAction(waitAction) {
                self.paddleSpeedMult = 1.0
                self.isPaddleSlowed = false
            }
        }
    }
    private func increaseBallSpeed() {
        if let plate = self.frame?.plate, let ball = self.ball {
            let upperBorder = ball.upperBorderVelocityTrigger
            let lowerBorder = ball.lowerBorderVelocityTrigger
            let lengthConstant = ball.lengthOfBallVelocityConstant
            
            self.ball?.upperBorderVelocityTrigger = upperBorder + upperBorder*1.3
            self.ball?.lowerBorderVelocityTrigger = lowerBorder + lowerBorder*1.3
            self.ball?.lengthOfBallVelocityConstant = lengthConstant * 1.3
            
            let waitAction = SCNAction.wait(duration: self.ballSpeededDuration)
            plate.runAction(waitAction) {
                self.ball?.upperBorderVelocityTrigger = upperBorder
                self.ball?.lowerBorderVelocityTrigger = lowerBorder
                self.ball?.lengthOfBallVelocityConstant = lengthConstant
                self.isBallSpeeded = false
            }
        }
    }
    private func addLive() {
        self.losedLives = max(0, self.losedLives - 1)
        self.lives += 1
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        self.pauseGame()
        self.performSegue(withIdentifier: "FromARGameToARPause", sender: self)
    }
    
    // загружаем все уровни
    func loadAllLevelsInfo() {
        
        for i in 1...UserProgress._3DmaxLevelIndex {
            if let path = Bundle.main.path(forResource: "level_\(i)", ofType: "txt") {
                if let text = try? String(contentsOfFile: path) {
                    var rows: UInt = 0, cols: UInt = 0
                    var descriptionOfLevel = [UInt]()
                    
                    var _3StarTime = TimeInterval()
                    var _2StarTime = TimeInterval()
                    
                    let stringsArray = text.components(separatedBy: "\n")
                    rows = UInt(stringsArray.count)
                    
                    if !stringsArray.isEmpty {
                        cols = UInt(stringsArray[0].components(separatedBy: " ").count)
                    }
                    
                    for string in stringsArray {
                        let healthArray = string.components(separatedBy: " ")
                        if healthArray.count == 1 && healthArray[0] == "" {
                            rows-=1
                        } else {
                            for health in healthArray {
                                if let health = UInt(health) {
                                    _3StarTime += 3.5 * TimeInterval(health)
                                    _2StarTime += 4 * TimeInterval(health)
                                    descriptionOfLevel.append(health)
                                }
                            }
                        }
                        
                    }
                    // создаем перевернутый массив с информацией о кирпичиках из-за особенностей считывания в Level3D
                    var reversedDescriptionOfLevel = [UInt]()
                    var i = descriptionOfLevel.count-1
                    while i >= 0 {
                        reversedDescriptionOfLevel.append(descriptionOfLevel[i])
                        i-=1
                    }
                    let level = Level3D(rows: rows, cols: cols, bricksDescription: reversedDescriptionOfLevel, _3StarTime: _3StarTime, _2StarTime: _2StarTime)
                    self.levels.append(level)
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
                                        y: planeNodePosition.y + 3*plateVolume.y,
                                        z: planeNodePosition.z)
            if let gameScene = self.gameScene {
                self.frame?.add(to: gameScene, in: framePosition)
            }
        }
//        let constraint = SCNBillboardConstraint()
//        constraint.freeAxes = .Y
        
//        constraint.localFront = SCNVector3(0, 0, 1)
        
//        self.frame?.plate.constraints = [constraint]
        
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
        livesTextNodeMaterial.diffuse.contents = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        livesTextNodeMaterial.specular.contents = #colorLiteral(red: 1, green: 0, blue: 0.8277662396, alpha: 1)
        
        livesTextNodeGeometry.materials = [livesTextNodeMaterial]
        // с горем пополам настраиваем позицию текста так, чтобы она была сверху слева от передней стенки
        self.livesLabel.name = "LivesLabel"
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
        
        self.paddle?.setPaddleSkin()
        self.particle?.setParticlesSkin()
        self.ball?.setBallSkin()
    }
    /// ставит игру на паузу
    func pauseGame() {
        self.isPaused = true
        self.starSpriteKitScene?.isPaused = true
        self.gameScene?.rootNode.isPaused = true
        self.gameScene?.physicsWorld.speed = 0
        
    }
    /// убирает игру с паузы
    func unpauseGame() {
        self.isPaused = false
        self.starSpriteKitScene?.isPaused = false
        self.gameScene?.rootNode.isPaused = false
        self.gameScene?.physicsWorld.speed = 1
        
        self.paddle?.setPaddleSkin()
        self.particle?.setParticlesSkin()
        self.ball?.setBallSkin()
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
        lightObject.drawsArea = true

        lightObject.shadowMode = SCNShadowMode.forward
        lightObject.castsShadow = true
        lightObject.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.85)
        
        lightObject.color = #colorLiteral(red: 0.9999999404, green: 1, blue: 1, alpha: 1)
        
        lightObject.shadowRadius = 12
        lightObject.shadowBias = 40
        
        lightObject.shadowMapSize = CGSize(width: 2048, height: 2048)
        lightObject.shadowSampleCount = 128
        lightObject.intensity = 2000
        
        self.light.light = lightObject
//        if let planeNodePosition = self.planeNodePosition {
//            let lighPosition = SCNVector3(x: planeNodePosition.x,
//                                          y: planeNodePosition.y + 1.0,
//                                          z: planeNodePosition.z - 0.4)
//            self.light.position = lighPosition
//        }
        self.light.position = SCNVector3(x: 0.0, y: 1.0, z: -0.4)
        self.light.name = "Light"
        if let gameScene = self.gameScene {
            gameScene.rootNode.addChildNode(self.light)
        }
        
        if let purpleLightObject = lightObject.copy() as? SCNLight {
            let lightNode = SCNNode()
            
            purpleLightObject.color = #colorLiteral(red: 0.9999999404, green: 1, blue: 1, alpha: 1)
            lightNode.light = purpleLightObject
            lightNode.position = SCNVector3(x: 0, y: 0.1, z: 0.5)
            
//            self.gameScene?.rootNode.addChildNode(lightNode)
        }
        
        let ambientLightNode = SCNNode()
        
        let ambientLight = SCNLight()
        
        ambientLightNode.position = SCNVector3(0.0, 0.25, -0.15)
        ambientLight.type = .ambient
        lightObject.shadowMode = SCNShadowMode.forward
        lightObject.castsShadow = true
        lightObject.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.85)
        
        lightObject.color = #colorLiteral(red: 0.9999999404, green: 1, blue: 1, alpha: 1)
        
        lightObject.shadowRadius = 12
        lightObject.shadowBias = 40
        
        lightObject.shadowMapSize = CGSize(width: 2048, height: 2048)
        lightObject.shadowSampleCount = 128
        lightObject.intensity = 500
        
        ambientLightNode.light = ambientLight
//        self.gameScene?.rootNode.addChildNode(ambientLightNode)
    }
    
    private func updatePhysicsBodyScale(node: SCNNode, scale: SCNVector3) {
        if let body = node.physicsBody {
            let oldShape = body.physicsShape
            if let newShapeSourceObject = oldShape?.sourceObject as? SCNGeometry {
                let newShape = SCNPhysicsShape(geometry: newShapeSourceObject, options: [.scale: scale])
                body.physicsShape = newShape
            }
        }
    }
}
extension ARGameViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let winViewController = segue.destination as? ARWinViewController {
            winViewController.gameScore = Int(score)
            winViewController.currentLevelIndex = self.levelChoosed
            winViewController.losedLives = self.losedLives
            winViewController.numberOfStars = self.numberOfStars
        }
        if let loseViewController = segue.destination as? ARLoseViewController {
            var losedMoney = 7 - self.score/4
            if losedMoney < 2 {
                losedMoney = 2
            } else if losedMoney > 10 {
                losedMoney = 10
            }
            loseViewController.losedMoney = Int(losedMoney)
        }
        if let pauseViewController = segue.destination as? ARPauseViewController {
            pauseViewController.wasGameSessionInterrupted = self.sessionWasInterrupted
            self.sessionWasInterrupted = false
        }
        
    }
}
extension ARGameViewController: ARCoachingOverlayViewDelegate {

}
// let hitlist = self.gameSceneView.hitTest(location, options: nil)
//for result in hitlist {
//    let resultNode = result.node
//    let duration = 0.6
//    if resultNode.name == "brick" {
//        let resizeAction = SCNAction.sequence([
//            SCNAction.scale(by: 0.5, duration: duration-0.1),
//            SCNAction.scale(by: 1/0.5, duration: duration-0.1)
//        ])
//        let rotateAction = SCNAction.rotate(by: 2*Double.pi, around: SCNVector3(x: 0, y: 1, z: 0), duration: duration+0.1)
//
//
//        let color1 = SCNVector3(x: 48/255, y: 62/255, z: 255/255)
//        let color2 = SCNVector3(x: 133/255, y: 237/255, z: 255/255)
//        let action1 = { (node: SCNNode, time: CGFloat) -> Void in
//            let percentage1 = time / (duration-0.1)
//            let percentage2 = 1 - time / (duration-0.1)
//            node.geometry?.firstMaterial?.diffuse.contents = UIColor.init(red: CGFloat(color1.x)*percentage1 +
//                                                                          CGFloat(color2.x)*percentage2,
//                                                                          green: CGFloat(color1.y)*percentage1 + CGFloat(color2.y)*percentage2,
//                                                                          blue: CGFloat(color1.z)*percentage1 + CGFloat(color2.z)*percentage2,
//                                                                          alpha: 1.0)
//
//        }
//
//        let action2 = { (node: SCNNode, time: CGFloat) -> Void in
//            let percentage1 = 1 - time / (duration-0.1)
//            let percentage2 = time / (duration-0.1)
//            node.geometry?.firstMaterial?.diffuse.contents = UIColor.init(red: CGFloat(color1.x)*percentage1 + CGFloat(color2.x)*percentage2,
//                                                                          green: CGFloat(color1.y)*percentage1 + CGFloat(color2.y)*percentage2,
//                                                                          blue: CGFloat(color1.z)*percentage1 + CGFloat(color2.z)*percentage2,
//                                                                          alpha: 1.0)
//        }
//        let customAction1 = SCNAction.customAction(duration: duration-0.1, action: action1)
//        customAction1.timingMode = SCNActionTimingMode.linear
//
//        let customAction2 = SCNAction.customAction(duration: duration-0.1, action: action2)
//
//        let colorizeAction = SCNAction.sequence([
//            customAction1,
//            customAction2
//        ])
//
//        result.node.runAction(SCNAction.group([
//            resizeAction,
//            colorizeAction,
//            rotateAction
//        ]))
//    }
//}
