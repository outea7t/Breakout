//
//  WinViewController.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 11.11.2022.
//

import UIKit
import SpriteKit
import ARKit

class ARWinViewController: UIViewController {

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var nextLevelButton: UIButton!
    
    deinit {
        print("ARWinViewController Deinitialization")
    }
    
    private var endGameScene: AREndGameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view.viewWithTag(1) as? SKView {
            skView.backgroundColor = .clear
            self.endGameScene = AREndGameScene(size: skView.bounds.size)
            self.endGameScene?.backgroundColor = .clear
            
            if let endGameScene = self.endGameScene {
                skView.presentScene(endGameScene)
            }
            
            
        }
        // настройка тени для кнопок (следующий уровень)
        self.nextLevelButton.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 0.1163903061, alpha: 1)
        self.nextLevelButton.layer.cornerRadius = 30
        self.nextLevelButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.6644610969, blue: 0.1157955602, alpha: 1)
        self.nextLevelButton.layer.shadowOffset = CGSize(width: nextLevelButton.frame.width*0.05,
                                                         height: nextLevelButton.frame.height*0.12)
        self.nextLevelButton.layer.shadowRadius = 0
        self.nextLevelButton.layer.shadowOpacity = 1.0
        self.nextLevelButton.layer.masksToBounds = false
        
        
        // кнопка меню
        self.menuButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.menuButton.layer.shadowOffset = CGSize(width: menuButton.frame.width*0.06,
                                                   height: menuButton.frame.height*0.06)
        self.menuButton.layer.shadowRadius = 4
        self.menuButton.layer.shadowOpacity = 1.0
        self.menuButton.layer.masksToBounds = false
        
        // кнопка перезапуска
        self.restartButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.restartButton.layer.shadowOffset = CGSize(width: restartButton.frame.width*0.06,
                                                         height: restartButton.frame.height*0.06)
        self.restartButton.layer.shadowRadius = 4
        self.restartButton.layer.shadowOpacity = 1.0
        self.restartButton.layer.masksToBounds = false
        
        // кнопка настроек
        self.settingsButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.settingsButton.layer.shadowOffset = CGSize(width: settingsButton.frame.width*0.06,
                                                         height: settingsButton.frame.height*0.06)
        self.settingsButton.layer.shadowRadius = 4
        self.settingsButton.layer.shadowOpacity = 1.0
        self.settingsButton.layer.masksToBounds = false
        
        // устанавливаем конфетти при выигрыше, настраиваем сцену
        self.setConfetti()
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
            if gameViewController.maxLevelIndex >= gameViewController.levelChoosed+1 {
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
        }
        self.dismiss(animated: true)
    }
}
