//
//  GameViewController.swift
//  Breakout
//
//  Created by Out East on 29.07.2022.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    // сцена с игрой
    var gameScene: GameScene?
    var levelChoosed = 1 {
        willSet {
            self.gameScene?.currentLevel?.removeAllBricksBeforeSettingLevel()
            self.gameScene?.currentLevel = self.levels[newValue-1]
            self.gameScene?.loadLevel()
        }
    }
    let maxLevelIndex = 30
    
    
    var isWin = false
    // массив со всеми уровнями
    private var levels = [Level2D]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view.viewWithTag(1) as? SKView {
            let scene = GameScene(size: view.bounds.size)
            
            scene.scaleMode = .aspectFill
            self.loadAllLevelsInfo()
            scene.currentLevel = self.levels[Int(self.levelChoosed)-1]
            view.presentScene(scene)
            // сцена с игрой
            self.gameScene = scene
            self.gameScene?.scaleMode = .aspectFill
            // подписываемся на делегат игры (для перехода на экран конца игры)
            self.gameScene?.gameVCDelegate = self
            
            view.ignoresSiblingOrder = true
            view.showsNodeCount = true
            view.showsFPS = true
        }
        self.gameScene?.currentLevel?.removeAllBricksBeforeSettingLevel()
        self.gameScene?.currentLevel = self.levels[self.levelChoosed-1]
        self.gameScene?.loadLevel()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    @objc func appMovedBackground() {
        // переходим к меню паузы и ставим игру на паузу
        self.performSegue(withIdentifier: "FromGameToPause", sender: self)
        self.gameScene?.pauseGame()
    }
    @objc func appMovedForeground() {
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
    
    // нажали кнопку паузы
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        // переходим к меню паузы и ставим игру на паузу
        self.performSegue(withIdentifier: "FromGameToPause", sender: self)
        self.gameScene?.pauseGame()
    
    }
    
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
                    let level = Level2D(rows: rows, cols: cols, bricksDescription: descriptionOfLevel)
                    self.levels.append(level)
                    
                }
            }
        }
    }

    
}

extension GameViewController: EndOfGameHandler {
    func moveToWinViewController() {
        HapticManager.winHaptic()
        self.performSegue(withIdentifier: "FromGameToWin", sender: self)
        self.gameScene?.pauseGame()
    }

    func moveToLoseViewController() {
        HapticManager.loseHaptic()
        self.performSegue(withIdentifier: "FromGameToLose", sender: self)
        self.gameScene?.pauseGame()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let gameScene = self.gameScene else {
            return
        }
        if let winViewController = segue.destination as? WinViewController {
            var scoredMoney = gameScene.score
            if gameScene.losedLives == 0 {
                
            } else if gameScene.losedLives == 1 {
                scoredMoney = scoredMoney*0.9
            } else if gameScene.losedLives == 2 {
                scoredMoney = scoredMoney*0.8
            } else if gameScene.losedLives == 3 {
                scoredMoney = scoredMoney*0.75
            } else if gameScene.losedLives > 3 {
                scoredMoney = scoredMoney*0.65
            }
            
            winViewController.scoredMoney = Int(scoredMoney/3)
        }
        if let loseViewController = segue.destination as? LoseViewController {
            var losedMoney = 10 - gameScene.score/4
            
            if losedMoney < 2 {
                losedMoney = 2
            } else if losedMoney > 10 {
                losedMoney = 10
            }
            loseViewController.losedMoney = Int(losedMoney)
        }
    }

}
