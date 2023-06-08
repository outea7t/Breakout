//
//  WinViewController.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 11.11.2022.
//

import UIKit
import SpriteKit
import ARKit
import RiveRuntime

class ARWinViewController: UIViewController {
    private enum StarAnimationsName: String {
        case _3 = "3StarAnimation"
        case _2 = "2StarAnimation"
        case _1 = "1StarAnimation"
    }
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var nextLevelButton: UIButton!
    
    
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var endGameView: SKView!
    @IBOutlet weak var scoredMoneyLabel: CountingLabel!
    @IBOutlet weak var userMoney: UILabel!
    
    deinit {
        print("ARWinViewController Deinitialization")
    }
    private var endGameScene: EndGameScene?
    
    private let backgroundView = RiveView()
    private let backgroundViewModel = RiveViewModel(fileName: "arpausemenu")
    
    private let starRiveView = RiveView()
    private let starRiveViewModel = RiveViewModel(fileName: "stars")
    
    var gameScore: Int = 0
    var currentLevelIndex: Int = 0
    var losedLives: Int = 0
    var numberOfStars: Int = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundViewModel.setView(self.backgroundView)
        self.backgroundViewModel.play(animationName: "AmbientAnimation", loop: .loop)
        self.backgroundViewModel.alignment = .center
        self.backgroundViewModel.fit = .fill
        
        self.view.addSubview(self.backgroundView)
        
        self.view.sendSubviewToBack(self.endGameView)
        self.view.sendSubviewToBack(self.backgroundView)
        self.view.sendSubviewToBack(self.blurView)
        
        self.backgroundView.frame = self.view.bounds
        self.backgroundView.center = self.view.center
        
        self.view.backgroundColor = .clear
        if let skView = self.view.viewWithTag(1) as? SKView {
            skView.backgroundColor = .clear
            self.endGameScene = EndGameScene(size: self.view.bounds.size)
            self.endGameScene?.backgroundColor = .clear
            
            if let endGameScene = self.endGameScene {
                skView.presentScene(endGameScene)
            }
        }
        
        let scoredMoney = self.countUserMoney()
        self.scoredMoneyLabel.count(fromValue: 0,
                                    to: Float(scoredMoney),
                                    withDuration: 1.0,
                                    animationType: .easeOut,
                                    counterType: .int,
                                    counterSign: .plus
        )
        
        GameCurrency.userMoney += scoredMoney
        self.userMoney.text = GameCurrency.updateUserMoneyLabel()
        
        UserProgress._3DmaxAvailableLevelID = max(self.currentLevelIndex + 1, UserProgress._3DmaxAvailableLevelID)
        UserProgress._3DlevelsStars[self.currentLevelIndex-1] = max(self.numberOfStars, UserProgress._3DlevelsStars[self.currentLevelIndex-1])
        UserProgress.totalScore += self.gameScore
        
        self.starRiveViewModel.setView(self.starRiveView)
        if self.numberOfStars == 3 {
            self.starRiveViewModel.play(animationName: StarAnimationsName._3.rawValue)
        } else if self.numberOfStars == 2 {
            self.starRiveViewModel.play(animationName: StarAnimationsName._2.rawValue)
        } else {
            self.starRiveViewModel.play(animationName: StarAnimationsName._1.rawValue)
        }
        
        self.starView.addSubview(self.starRiveView)
        self.starRiveView.center = self.starView.center
        self.starRiveView.frame = self.starView.bounds
        self.starRiveViewModel.fit = .fill
        
        self.endGameScene?.isWin = true
        self.endGameScene?.setText()
        self.endGameScene?.setAnimatedParticles()
        // устанавливаем конфетти при выигрыше, настраиваем сцену
        self.setConfetti()
    }
    private func countUserMoney() -> Int {
        var scoredMoney = Double(self.gameScore)
        if self.losedLives == 0 {
            
        } else if self.losedLives == 1 {
            scoredMoney *= 0.95
        } else if self.losedLives == 2 {
            scoredMoney *= 0.9
        } else if self.losedLives == 3 {
            scoredMoney *= 0.8
        } else if self.losedLives > 3 {
            scoredMoney *= 0.75
        }
        return Int(scoredMoney/2.2)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scoredMoneyLabel.invalidateTimer()
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    func setConfetti() {
        self.endGameScene?.isWin = true
        self.endGameScene?.addConfetti()
        self.endGameScene?.setText()
        self.endGameScene?.setAnimatedParticles()
    }
    // кнопка возвращения в меню
    @IBAction func homeButtonPressed(_ sender: UIButton) {
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            self.endGameScene = nil
            print("tried to clean")
            gameViewController.gameScene?.physicsWorld.contactDelegate = nil
            gameViewController.gameSceneView.delegate = nil
            gameViewController.gameScene = nil
        }
        // unwind к меню из сториборда
    }
    // кнопка перезапуска уровня
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            self.endGameScene = nil
            gameViewController.unpauseGame()
            gameViewController.restartGame()
            // обновляем ARSession, чтобы не было проблем с environment texturing
            gameViewController.updateConfiguration()
            gameViewController.removeAllChildren()
            gameViewController.wantDetectPlane = true
            gameViewController.wantSetPosition = true
            gameViewController.isFramePositionPinned = false
            gameViewController.score = 0
            gameViewController.losedLives = 0
            gameViewController.isFirstBallLaunch = true
            gameViewController.starSpriteKitScene?.stars?.clearActions()
        }
        self.dismiss(animated: true)
    }
    // кнопка вызова меню настроек
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
       
    }
    // кнопка с переходом к следующему уровню
    @IBAction func nextLevelButtonPressed(_ sender: UIButton) {
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            self.endGameScene = nil
            if UserProgress._3DmaxLevelIndex >= gameViewController.levelChoosed+1 {
                gameViewController.levelChoosed += 1
            } else {
                gameViewController.levelChoosed = 1
            }
            
            gameViewController.unpauseGame()
            gameViewController.lives += 1
            
            gameViewController.updateConfiguration()
            gameViewController.removeAllChildren()
            gameViewController.wantDetectPlane = true
            gameViewController.wantSetPosition = true
            gameViewController.isFramePositionPinned = false
            gameViewController.score = 0
            gameViewController.losedLives = 0
            gameViewController.isFirstBallLaunch = true
            gameViewController.starSpriteKitScene?.stars?.clearActions()
        }
        self.dismiss(animated: true)
    }
}
