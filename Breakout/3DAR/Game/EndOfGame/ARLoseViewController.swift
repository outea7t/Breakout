//
//  ViewController.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 10.11.2022.
//

import UIKit
import SpriteKit

class ARLoseViewController: UIViewController {

    @IBOutlet weak var restartButton: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var menuButton: UIButton!
    
    var endGameScene: AREndGameScene?
    
    deinit {
        print("ARLoseViewController Deinitialization")
    }
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
        self.restartButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491002738, blue: 0, alpha: 1)
        self.restartButton.layer.cornerRadius = 30
        self.restartButton.layer.shadowColor = #colorLiteral(red: 0.5262494683, green: 0, blue: 0, alpha: 1)
        self.restartButton.layer.shadowOffset = CGSize(width: restartButton.frame.width*0.05,
                                                       height: restartButton.frame.height*0.12)
        self.restartButton.layer.shadowRadius = 4
        self.restartButton.layer.shadowOpacity = 1.0
        self.restartButton.layer.masksToBounds = false
        
        
        self.infoLabel.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.infoLabel.layer.shadowOffset = CGSize(width: infoLabel.frame.width*0.025,
                                                   height: infoLabel.frame.height*0.025)
        self.infoLabel.layer.shadowRadius = 4
        self.infoLabel.layer.shadowOpacity = 1.0
        self.infoLabel.layer.masksToBounds = false
        
        self.menuButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.menuButton.layer.shadowOffset = CGSize(width: menuButton.frame.width*0.025,
                                                   height: menuButton.frame.height*0.025)
        self.menuButton.layer.shadowRadius = 4
        self.menuButton.layer.shadowOpacity = 1.0
        self.menuButton.layer.masksToBounds = false
        
        self.settingsButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.settingsButton.layer.shadowOffset = CGSize(width: settingsButton.frame.width*0.025,
                                                   height: settingsButton.frame.height*0.025)
        self.settingsButton.layer.shadowRadius = 4
        self.settingsButton.layer.shadowOpacity = 1.0
        self.settingsButton.layer.masksToBounds = false
        
        self.setConfetti()
        // Do any additional setup after loading the view.
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
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            self.endGameScene = nil
            gameViewController.gameScene?.physicsWorld.contactDelegate = nil
            gameViewController.gameSceneView.delegate = nil
            gameViewController.gameScene = nil
        }
        // unwind к меню из сториборда
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            self.endGameScene = nil
            gameViewController.unpauseGame()
            gameViewController.restartGame()
            gameViewController.updateConfiguration()
            gameViewController.removeAllChildren()
            gameViewController.wantDetectPlane = true
            gameViewController.wantSetPosition = true
        }
        self.dismiss(animated: true)
    }
    
}
