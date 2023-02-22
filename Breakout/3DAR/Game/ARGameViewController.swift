//
//  ViewController.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 15.08.2022.
//

import UIKit
import SceneKit
import ARKit



class ARGameViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var gameSceneView: ARSCNView!
    weak var gameScene: ARGameScene?
    
    var levelChoosed: Int = 1 {
        willSet {
            self.gameScene?.currentLevel?.removeAllBricksBeforeSettingLevel()
            self.gameScene?.currentLevel = self.levels[newValue-1]
            self.gameScene?.loadLevel()
        }
    }
    private var levels = [Level3D]()
    let maxLevelIndex = 30
    
    deinit {
        print("ARGameViewController Deinitialization")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // настраиваем debug опции
        self.gameSceneView.debugOptions = [.showFeaturePoints, .showLightExtents]
        
        // устанавливаем делегат для AR
        self.gameSceneView.delegate = self
        
        // показывать статистику (ФПС И КОЛ-ВО nodes)
        self.gameSceneView.showsStatistics = true
        self.gameSceneView.allowsCameraControl = false
        self.gameSceneView.autoenablesDefaultLighting = true
        
//        self.gameSceneView.renderingAPI
//        self.gameSceneView.pointOfView?.camera?.wantsHDR = true
//        self.gameSceneView.pointOfView?.camera?.minimumExposure = -1
//        self.gameSceneView.pointOfView?.camera?.maximumExposure = -1
        // создаем новую сцену
        let scene = ARGameScene()
        self.gameScene = scene
        
        // устанавливаем делегат для перехода в меню конца игры из сцены
        self.gameScene?.gameVCDelegate = self
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
        // загужаем все уровни
        self.loadAllLevelsInfo()
        
        self.gameScene?.currentLevel?.removeAllBricksBeforeSettingLevel()
        self.gameScene?.currentLevel = self.levels[self.levelChoosed-1]
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        // создаем конфигурацию сессии
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic

        // телефон должен иметь конфигурацию отслеживания мира
        self.gameSceneView.session.run(configuration)
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
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        self.gameScene?.renderer(renderer, didAdd: node, for: anchor)
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.gameScene?.renderer(renderer, didUpdate: node, for: anchor)
    }
    /// показывает сообщение об ошибке пользователю
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    /// вызывается, когда сессия прерывается
    func sessionWasInterrupted(_ session: ARSession) {
        self.gameScene?.pauseGame()
        self.performSegue(withIdentifier: "FromARGameToARPause", sender: self)
    }
    /// вызывается, когда сессия возобновляется
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.gameScene?.renderer(renderer, updateAtTime: time)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gameScene?.touchesBegan(touches, with: event, sceneView: self.gameSceneView)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gameScene?.touchesMoved(touches, with: event, sceneView: self.gameSceneView)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gameScene?.touchesEnded(touches, with: event)
    }
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        self.gameScene?.physicsWorld(world, didBegin: contact)
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        self.gameScene?.pauseGame()
        self.performSegue(withIdentifier: "FromARGameToARPause", sender: self)
    }
    
    // загружаем все уровни
    private func loadAllLevelsInfo() {
        for i in 1...self.maxLevelIndex {
            if let path = Bundle.main.path(forResource: "level_\(i)", ofType: "txt") {
                if let text = try? String(contentsOfFile: path) {
                    var rows: UInt = 0, cols: UInt = 0
                    var descriptionOfLevel = [UInt]()
                    
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
                    print(reversedDescriptionOfLevel)
                    let level = Level3D(rows: rows, cols: cols, bricksDescription: reversedDescriptionOfLevel)
                    self.levels.append(level)
                    
                }
            }
        }
    }
}

// для перехода из сцены с игрой в меню конца игры
extension ARGameViewController: AREndOfGameHandler {
    // ставим игру на паузу
    func moveToWinViewColtroller() {
        self.gameScene?.pauseGame()
        HapticManager.winHaptic()
        self.performSegue(withIdentifier: "FromARGameToARWin", sender: self)
    }
    // ставим игру на паузу
    func moveToLoseViewController() {
        self.gameScene?.pauseGame()
        HapticManager.loseHaptic()
        self.performSegue(withIdentifier: "FromARGameToARLose", sender: self)
    }
}
