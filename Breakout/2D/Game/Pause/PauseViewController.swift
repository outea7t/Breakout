//
//  PauseViewController.swift
//  Breakout
//
//  Created by Out East on 29.07.2022.
//

import UIKit
import SpriteKit
import RiveRuntime

class PauseViewController: UIViewController {

    weak var pauseScene: PauseScene?
    
    @IBOutlet weak var pauseView: SKView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    
    private let backgroundView = RiveView()
    private let backgroundViewModel = RiveViewModel(fileName: "pausemenu")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // настраиваем riveView
        self.backgroundViewModel.setView(self.backgroundView)
        self.backgroundViewModel.play(loop: .loop)
        
        self.backgroundViewModel.alignment = .topLeft
        self.backgroundViewModel.fit = .fill
        self.view.addSubview(self.backgroundView)
        
        self.view.sendSubviewToBack(self.pauseView)
        self.view.sendSubviewToBack(self.backgroundView)
        self.view.sendSubviewToBack(self.blurView)
        
        self.backgroundView.frame = self.view.bounds
        self.backgroundView.center = self.view.center
        
        if let view = self.view.viewWithTag(1) as? SKView {
            view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            let scene = PauseScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            self.pauseScene = scene
        
            view.ignoresSiblingOrder = true
            view.showsNodeCount = true
            view.showsFPS = true
            view.showsPhysics = true
        }
        
//        self.setShadow(for: self.homeButton)
//        self.setShadow(for: self.settingsButton)
//        self.setShadow(for: self.restartButton)
        
        self.resumeButton.layer.cornerRadius = self.restartButton.frame.height/4.0
        
        let resumeButtonShadowColor = #colorLiteral(red: 0.4924743176, green: 0.1744754016, blue: 0.0226278659, alpha: 1)
        self.resumeButton.layer.shadowColor = resumeButtonShadowColor.cgColor
        self.resumeButton.layer.shadowOpacity = 0.0
        self.resumeButton.layer.shadowRadius = 0
        self.resumeButton.layer.shadowOffset = CGSize(width: self.resumeButton.frame.width/30,
                                                      height: self.resumeButton.frame.height/10)
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

    
    @IBAction func quitButtonPressed(_ sender: UIButton) {
        // unwind к меню из сториборда
        self.pauseScene = nil
        if let gameViewController = self.presentationController?.presentingViewController as? GameViewController {
            gameViewController.gameScene?.gameVCDelegate = nil
            gameViewController.gameScene = nil
        }
    }
    override func delete(_ sender: Any?) {
        super.delete(sender)
        print("delete")
    }
    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        self.pauseScene = nil
        if let gameViewController = self.presentationController?.presentingViewController as? GameViewController {
            gameViewController.gameScene?.unpauseGame()
//            gameViewController.gameScene?.setBallSkin()
//            gameViewController.gameScene?.setParticlesSkin()
        }
        self.dismiss(animated: true)
    }
    
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        self.pauseScene = nil
        if let gameViewController = self.presentationController?.presentingViewController as? GameViewController {
            
            gameViewController.gameScene?.resetTheGame()
            gameViewController.gameScene?.unpauseGame()
//            gameViewController.gameScene?.setBallSkin()
//            gameViewController.gameScene?.setParticlesSkin()
        }
        self.dismiss(animated: true)
    }
    
    private func setShadow(for button: UIButton) {
        let shadowColor = #colorLiteral(red: 0.01247970853, green: 0, blue: 0.4472637177, alpha: 1)
        button.layer.shadowColor = shadowColor.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: button.frame.width/10,
                                           height: button.frame.height/10)
    }
}
