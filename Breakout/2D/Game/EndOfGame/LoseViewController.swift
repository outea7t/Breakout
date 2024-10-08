//
//  EndGameViewController.swift
//  Breakout
//
//  Created by Out East on 30.07.2022.
//

import UIKit
import SpriteKit

class LoseViewController: UIViewController {

    
    @IBOutlet weak var infoLabel: UILabel!
    var endGameScene: EndGameScene?
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    // аутлеты с кнопками для их настройки
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view.viewWithTag(1) as? SKView {
//            view.backgroundColor = #colorLiteral(red: 0.6630792942, green: 0, blue: 0, alpha: 0.2)
            view.backgroundColor = .clear
            let scene = EndGameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.size = view.bounds.size
            
            self.endGameScene = scene
            view.presentScene(scene)
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        self.setConfetti()
        self.restartButton.layer.cornerRadius = 30
        self.restartButton.layer.shadowOpacity = 1.0
        self.restartButton.layer.shadowRadius = 0.0
        self.restartButton.layer.shadowColor = #colorLiteral(red: 0.4212525189, green: 0.03159917518, blue: 0.02470676601, alpha: 1)
        self.restartButton.layer.shadowOffset = CGSize(width: self.restartButton.frame.width/30.0,
                                                       height: self.restartButton.frame.height/10.0)
        
        self.setShadow(for: self.homeButton)
        self.setShadow(for: self.settingsButton)
        
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
        self.endGameScene?.isWin = false
        self.endGameScene?.addConfetti()
        self.endGameScene?.setText()
    }

    @IBAction func restartButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.endGameScene = nil
        if let gameViewController = self.presentationController?.presentingViewController as? GameViewController {
            print("restarted")
            gameViewController.gameScene?.unpauseGame()
            gameViewController.gameScene?.resetTheGame()
            gameViewController.gameScene?.setBallSkin()
            gameViewController.gameScene?.setParticlesSkin()
        }
    }
    
    @IBAction func mainMenuButtonPressed(_ sender: UIButton) {
        self.endGameScene = nil
        if let gameViewController = self.presentationController?.presentingViewController as? GameViewController {
            gameViewController.gameScene?.gameVCDelegate = nil
            gameViewController.gameScene = nil
            print("RELEASED - \(gameViewController.gameScene)")
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
    }
    private func setShadow(for button: UIButton) {
        let shadowColor = #colorLiteral(red: 0.4148173928, green: 0.01940291375, blue: 0.01605514064, alpha: 1)
        button.layer.shadowColor = shadowColor.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: button.frame.width/10,
                                           height: button.frame.height/10)
    }
}
