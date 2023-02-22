//
//  WinViewController.swift
//  Breakout
//
//  Created by Out East on 23.11.2022.
//

import UIKit
import SpriteKit


class WinViewController: UIViewController {

    
    var endGameScene: EndGameScene?
    
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var nextLevelButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view.viewWithTag(1) as? SKView {
//            view.backgroundColor = #colorLiteral(red: 0, green: 0.6370642007, blue: 0, alpha: 0.2)
            view.backgroundColor = .clear
            let scene = EndGameScene()
            scene.scaleMode = .aspectFill
            scene.size = view.bounds.size
//            scene.backgroundColor =
            
            self.endGameScene = scene
//            self.endGameScene?.isWin = true
//            self.endGameScene?.setText()
            view.presentScene(scene)
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        self.nextLevelButton.layer.cornerRadius = self.nextLevelButton.frame.height/4
        self.nextLevelButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.2737032313, blue: 0, alpha: 1)
        self.nextLevelButton.layer.shadowOpacity = 1
        self.nextLevelButton.layer.shadowRadius = 0
        self.nextLevelButton.layer.shadowOffset = CGSize(width: self.nextLevelButton.frame.width/30,
                                                         height: self.nextLevelButton.frame.height/10.0)
        
        self.setShadow(for: self.homeButton)
        self.setShadow(for: self.restartButton)
        self.setShadow(for: self.settingsButton)
        // Do any additional setup after loading the view.
        self.setConfetti()
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
    
    func setConfetti() {
        self.endGameScene?.isWin = true
        self.endGameScene?.addConfetti()
        self.endGameScene?.setText()
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
            gameViewController.gameScene?.unpauseGame()
            gameViewController.gameScene?.resetTheGame()
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
    
    private func setShadow(for button: UIButton) {
        let shadowColor = #colorLiteral(red: 0.01421812456, green: 0.2760511935, blue: 0.02150881477, alpha: 1)
        button.layer.shadowColor = shadowColor.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: button.frame.width/10,
                                           height: button.frame.height/10)
    }
}
