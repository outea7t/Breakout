//
//  ViewController.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 10.11.2022.
//

import UIKit
import SpriteKit
import RiveRuntime

class ARLoseViewController: UIViewController {

    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var endGameView: SKView!
    
    var endGameScene: EndGameScene?
    
    deinit {
        print("ARLoseViewController Deinitialization")
    }
    
    private let backgroundView = RiveView()
    private let backgroundViewModel = RiveViewModel(fileName: "pausemenu")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundViewModel.setView(self.backgroundView)
        self.backgroundViewModel.play(animationName: "AmbientAnimation", loop: .loop)
        
        self.view.addSubview(self.backgroundView)
        
        self.view.sendSubviewToBack(self.endGameView)
        self.view.sendSubviewToBack(self.backgroundView)
        self.view.sendSubviewToBack(self.blurView)
        
        self.backgroundView.frame = self.view.bounds
        self.backgroundView.center = self.view.center
        
        if let skView = self.view.viewWithTag(1) as? SKView {
            skView.backgroundColor = .clear
            self.endGameScene = EndGameScene(size: skView.bounds.size)
            self.endGameScene?.backgroundColor = .clear
            
            if let endGameScene = self.endGameScene {
                skView.presentScene(endGameScene)
            }
        }
        
        self.restartButton.layer.cornerRadius = 30
        self.restartButton.layer.shadowColor = #colorLiteral(red: 0.2526390254, green: 0.01980083622, blue: 0.01480148733, alpha: 1)
        self.restartButton.layer.shadowOffset = CGSize(width: restartButton.frame.width*0.05,
                                                       height: restartButton.frame.height*0.12)
        self.restartButton.layer.shadowRadius = 0
        self.restartButton.layer.shadowOpacity = 0.0
        self.restartButton.layer.masksToBounds = false
        
        
        self.menuButton.layer.shadowColor = #colorLiteral(red: 0.2481062114, green: 0, blue: 0, alpha: 1)
        self.menuButton.layer.shadowOffset = CGSize(width: menuButton.frame.width*0.025,
                                                   height: menuButton.frame.height*0.025)
        self.menuButton.layer.shadowRadius = 0
        self.menuButton.layer.shadowOpacity = 0.0
        self.menuButton.layer.masksToBounds = false
        
        self.settingsButton.layer.shadowColor = #colorLiteral(red: 0.2235294118, green: 0, blue: 0.007843137255, alpha: 1)
        self.settingsButton.layer.shadowOffset = CGSize(width: settingsButton.frame.width*0.025,
                                                   height: settingsButton.frame.height*0.025)
        self.settingsButton.layer.shadowRadius = 0
        self.settingsButton.layer.shadowOpacity = 0.0
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
        self.endGameScene?.isWin = false
        self.endGameScene?.addConfetti()
        self.endGameScene?.setText()
        self.endGameScene?.setAnimatedParticles()
    }
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            print("yeeeees")
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
