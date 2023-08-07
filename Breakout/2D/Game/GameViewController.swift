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
    
    @IBOutlet weak var pauseButton: UIButton!
    
    weak var gameScene: GameScene?
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
            let scene = GameScene(size: self.view.bounds.size)
            scene.scaleMode = .aspectFill
            self.loadAllLevelsInfo()
            scene.currentLevel = self.levels[Int(self.levelChoosed)-1]
            view.presentScene(scene)
            // сцена с игрой
            self.gameScene = scene
            // подписываемся на делегат игры (для перехода на экран конца игры)
            self.gameScene?.gameVCDelegate = self
            
            view.ignoresSiblingOrder = true
//            view.showsNodeCount = true
//            view.showsFPS = true
        }
        self.gameScene?.currentLevel?.removeAllBricksBeforeSettingLevel()
        self.gameScene?.currentLevel = self.levels[self.levelChoosed-1]
        self.gameScene?.loadLevel()
        
        
        if !UserCustomization._2DbuyedLevelColorSchemeIndexes.isEmpty {
            self.pauseButton.tintColor = Brick2D.currentLevelColorScheme.starFillColor
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // располагаем кнопку с паузой под кирпичиками слева
        self.pauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        var pauseButtonConstraints = [NSLayoutConstraint]()
        
        pauseButtonConstraints.append(self.pauseButton.widthAnchor.constraint(equalToConstant: 130/844 * self.view.frame.height))
        pauseButtonConstraints.append(self.pauseButton.heightAnchor.constraint(equalToConstant: 130/844 * self.view.frame.height))
        pauseButtonConstraints.append(self.pauseButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0))
        pauseButtonConstraints.append(self.pauseButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 130/844*self.view.frame.height/2))
        
        NSLayoutConstraint.activate(pauseButtonConstraints)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.pauseButton.frame.origin.y = self.view.frame.midY + self.pauseButton.frame.size.height/4
        if !UserCustomization._2DbuyedLevelColorSchemeIndexes.isEmpty {
            self.pauseButton.tintColor = Brick2D.currentLevelColorScheme.starFillColor
        }
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
    /// функция, загружающая всю информацию об уровнях
    private func loadAllLevelsInfo() {
        for i in 1...self.maxLevelIndex {
            if let path = Bundle.main.path(forResource: "level_\(i)", ofType: "txt") {
                if let text = try? String(contentsOfFile: path) {
                    var rows: UInt = 0, cols: UInt = 0
                    var descriptionOfLevel = [UInt]()
                    
                    var _3StarTime = TimeInterval()
                    var _2StarTime = TimeInterval()
                    
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
                                    _3StarTime += 2.75 * TimeInterval(health)
                                    _2StarTime += 3.5 * TimeInterval(health)
                                    descriptionOfLevel.append(health)
                                }
                            }
                        }
                        
                    }
                    let level = Level2D(rows: rows, cols: cols, bricksDescription: descriptionOfLevel, _3StarTime: _3StarTime, _2StarTime: _2StarTime)
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
            winViewController.gameScore = Int(gameScene.score)
            winViewController.currentLevelIndex = self.levelChoosed
            winViewController.losedLives = gameScene.losedLives
            winViewController.numberOfStars = gameScene.numberOfStars
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
