//
//  WinViewController.swift
//  Breakout
//
//  Created by Out East on 23.11.2022.
//

import UIKit
import SpriteKit
import RiveRuntime

class WinViewController: UIViewController {
    enum StarAnimationsName: String {
        case _3 = "3StarAnimation"
        case _2 = "2StarAnimation"
        case _1 = "1StarAnimation"
    }
    
    @IBOutlet weak var scoredMoneyLabel: CountingLabel!
    @IBOutlet weak var starView: UIView!
    weak var endGameScene: EndGameScene!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var endGameView: SKView!
    
    @IBOutlet weak var nextLevelButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var userMoney: UILabel!
    
    
    private let backgroundView = RiveView()
    private let backgroundViewModel = RiveViewModel(fileName: "pausemenu")
    
    private let starRiveView = RiveView()
    private let starRiveViewModel = RiveViewModel(fileName: "stars")
    /// Полученное количество денег
    var gameScore: Int = 0
    var currentLevelIndex: Int = 0
    var losedLives: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundViewModel.setView(self.backgroundView)
        self.backgroundViewModel.play(animationName: "AmbientAnimation", loop: .loop)
        self.backgroundViewModel.fit = .fill
        
        self.view.addSubview(self.backgroundView)
        
        self.view.sendSubviewToBack(self.endGameView)
        self.view.sendSubviewToBack(self.backgroundView)
        self.view.sendSubviewToBack(self.blurView)
        
        self.backgroundView.frame = self.view.bounds
        self.backgroundView.center = self.view.center
        
        if let view = self.view.viewWithTag(1) as? SKView {
            view.backgroundColor = .clear
            let scene = EndGameScene(size: self.view.bounds.size)
            scene.scaleMode = .aspectFill
            self.endGameScene = scene
            view.presentScene(scene)
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        self.nextLevelButton.layer.cornerRadius = self.nextLevelButton.frame.height/4
        self.nextLevelButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.2737032313, blue: 0, alpha: 1)
        self.nextLevelButton.layer.shadowOpacity = 0.0
        self.nextLevelButton.layer.shadowRadius = 0
        self.nextLevelButton.layer.shadowOffset = CGSize(width: self.nextLevelButton.frame.width/30,
                                                         height: self.nextLevelButton.frame.height/10.0)
        
        let scoredMoney = self.countUserMoney()
        self.scoredMoneyLabel.count(fromValue: 0,
                                    to: Float(scoredMoney),
                                    withDuration: 1.0,
                                    animationType: .easeOut,
                                    counterType: .int,
                                    counterSign: .plus
        )
        
        self.userMoney.text = GameCurrency.updateUserMoneyLabel()
        GameCurrency.userMoney += scoredMoney
        
        UserProgress._2DmaxAvailableLevelID = max(self.currentLevelIndex + 1, UserProgress._2DmaxAvailableLevelID)
        UserProgress._2DlevelsStars[self.currentLevelIndex-1] = max(3, UserProgress._2DlevelsStars[self.currentLevelIndex-1])
        UserProgress.totalScore += self.gameScore
        
        self.starRiveViewModel.setView(self.starRiveView)
        self.starRiveViewModel.play(animationName: "3StarAnimation")
        
        self.starView.addSubview(self.starRiveView)
        self.starRiveView.center = self.starView.center
        self.starRiveView.frame = self.starView.bounds
        self.starRiveViewModel.fit = .fill
        
        self.endGameScene?.isWin = true
        self.endGameScene?.setText()
        self.endGameScene?.setAnimatedParticles()
        
        self.setConfetti()
    }
    
    
    private func countUserMoney() -> Int {
        var scoredMoney = Double(self.gameScore)
        if self.losedLives == 0 {
            
        } else if self.losedLives == 1 {
            scoredMoney *= 0.9
        } else if self.losedLives == 2 {
            scoredMoney *= 0.8
        } else if self.losedLives == 3 {
            scoredMoney *= 0.75
        } else if self.losedLives > 3 {
            scoredMoney *= 0.65
        }
        return Int(scoredMoney/3)
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scoredMoneyLabel.invalidateTimer()
    }
    func setConfetti() {
        self.endGameScene?.addConfetti()
    }
    @IBAction func mainMenuButtonPressed(_ sender: UIButton) {
        self.endGameScene = nil
        if let gameViewController = self.presentationController?.presentingViewController as? GameViewController {
            gameViewController.gameScene?.gameVCDelegate = nil
            gameViewController.gameScene = nil
        }
    }
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        self.endGameScene = nil
        if let gameViewController = self.presentationController?.presentingViewController as? GameViewController {
            gameViewController.gameScene?.resetTheGame()
            gameViewController.gameScene?.unpauseGame()
        }
        self.dismiss(animated: true)
    }
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
    }
    @IBAction func nextLevelButtonPressed(_ sender: UIButton) {
        self.endGameScene = nil
        if let gameViewController = self.presentationController?.presentingViewController as? GameViewController {
            gameViewController.gameScene?.unpauseGame()
            gameViewController.gameScene?.resetAfterWin()
            if gameViewController.levelChoosed + 1 <= gameViewController.maxLevelIndex {
                gameViewController.levelChoosed+=1
            } else {
                gameViewController.levelChoosed = 1
            }
            gameViewController.gameScene?.setBallSkin()
            gameViewController.gameScene?.setParticlesSkin()
        }
        self.dismiss(animated: true)
    }
    
    
}
