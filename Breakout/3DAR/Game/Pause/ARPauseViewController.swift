//
//  PauseViewController.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 04.11.2022.
//

import UIKit
import SceneKit
import SpriteKit

class ARPauseViewController: UIViewController {
    
    // кнопки и лейблы в меню паузы для их настройки из кода
    @IBOutlet weak var toMenuButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var resetLevelButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    
    deinit {
        print("ARPauseViewController Deinitialization")
    }
    
    private var pauseScene: ARPauseScene?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view.viewWithTag(1) as? SKView {
            skView.backgroundColor = .clear
            
            let scene = ARPauseScene(size: skView.bounds.size)
            scene.backgroundColor = .clear

            self.pauseScene = scene
            skView.presentScene(scene)
            
        }
        // настраиваем округлость кнопки и ее тень
        self.resumeButton.layer.cornerRadius = 30
        self.resumeButton.layer.shadowOpacity = 1.0
        self.resumeButton.layer.shadowColor = #colorLiteral(red: 0.2478538454, green: 0.1077214703, blue: 0.03691976517, alpha: 1)
        self.resumeButton.layer.shadowRadius = 0.0
        self.resumeButton.layer.shadowOffset = CGSize(width: self.resumeButton.frame.width/20,
                                                      height: self.resumeButton.frame.height/15)
        
        
        self.setShadowForRoundButtons(button: self.toMenuButton)
        self.setShadowForRoundButtons(button: self.settingsButton)
        self.setShadowForRoundButtons(button: self.resetLevelButton)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let arGameViewController = segue.destination as? ARGameViewController {
            arGameViewController.unpauseGame()
        }
    }
    
    
    // функции, отслеживающие нажатия кнопок
    // нажата кнопка продолжения игры
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            self.pauseScene = nil
            gameViewController.unpauseGame()
        }
        self.dismiss(animated: true)
    }
    
    // нажата кнопка возвращения в меню
    @IBAction func returnToARMenuPressed(_ sender: UIButton) {
        // из storyboard анвайндимся до ар меню
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            self.pauseScene = nil
            gameViewController.gameScene?.physicsWorld.contactDelegate = nil
            gameViewController.gameSceneView.delegate = nil
            gameViewController.gameScene = nil
        }
    }
    // нажата кнопка меню настроек
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
    
    }
    
    // нажата кнопка перезапуска уровня
    @IBAction func restartLevelButtonPressed(_ sender: UIButton) {
        if let gameViewController = self.presentationController?.presentingViewController as? ARGameViewController {
            self.pauseScene = nil
//            gameViewController.gameSceneView.session.pause()
            gameViewController.unpauseGame()
            gameViewController.restartGame()
//            gameViewController.removeAllChildren()
//            gameViewController.wantDetectPlane = true
//            gameViewController.wantSetPosition = true
            
        }
        self.dismiss(animated: true)
    }
    
    // настраиваем тени для круглых кнопок (их в этом меню много, поэтому код объединен в отдельную функцию)
    private func setShadowForRoundButtons(button: UIButton) {
        button.layer.shadowOpacity = 1.0
        button.layer.shadowColor = #colorLiteral(red: 0, green: 0.002615191974, blue: 0.2709097266, alpha: 1)
        button.layer.shadowRadius = 0.0
        button.layer.shadowOffset = CGSize(width: button.frame.width/13.0,
                                           height: button.frame.height/13.0)
    }
}
