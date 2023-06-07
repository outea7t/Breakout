//
//  GameViewController.swift
//  Breakout
//
//  Created by Out East on 22.07.2022.
//
import UIKit
import SpriteKit
import ARKit
import RiveRuntime

class MenuViewController: UIViewController {
    
    // сцена с меню
    var menuScene: MenuScene?
    
    // кнопки из меню (чтобы их изменять немного)
    @IBOutlet weak var levelsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var statisticButton: UIButton!
    @IBOutlet weak var arButton: UIButton!
    
    // количество денег игрока
    @IBOutlet weak var userMoney: UILabel!
    // задний фон из райва
    let backgroundView = RiveView()
    let backgroundViewModel = RiveViewModel(fileName: "background")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // настраиваем riveView
        self.backgroundViewModel.setView(self.backgroundView)
        self.backgroundViewModel.play(animationName: "backAnimation", loop: .loop)
        
        self.backgroundViewModel.alignment = .center
        self.backgroundViewModel.fit = .fill
        self.view.addSubview(self.backgroundView)
        self.view.sendSubviewToBack(self.backgroundView)
        
        self.backgroundView.frame = self.view.bounds
        self.backgroundView.center = self.view.center
        
        if let view = self.view.viewWithTag(1) as? SKView {
            view.backgroundColor = .clear
            let scene = MenuScene(size: self.view.bounds.size)
            scene.backgroundColor = .clear
            scene.scaleMode = .aspectFill // чтобы идеально подошли размеры сцены под view
            
            
            view.presentScene(scene)
            view.showsPhysics = true
            // сцена меню, чтобы можно было ей управлять
            self.menuScene = scene
        
            // настраиваем некоторые дебаг опции
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        self.levelsButton.layer.shadowOpacity = 1.0
        self.levelsButton.layer.shadowColor = #colorLiteral(red: 0.03684008494, green: 0.002703937935, blue: 0.0810591206, alpha: 1)
        self.levelsButton.layer.shadowRadius = 0.0
        self.levelsButton.layer.shadowOffset = CGSize(width: self.levelsButton.frame.width/30.0,
                                                      height: self.levelsButton.frame.height/10.0)

        self.settingsButton.layer.shadowOpacity = 1.0
        self.settingsButton.layer.shadowColor = #colorLiteral(red: 0.05542261899, green: 0.004148194566, blue: 0.1240254864, alpha: 1)
        self.settingsButton.layer.shadowRadius = 0.0
        self.settingsButton.layer.shadowOffset = CGSize(width: self.settingsButton.frame.width/30.0,
                                                      height: self.settingsButton.frame.height/10.0)
        
        self.arButton.layer.shadowOpacity = 1.0
        self.arButton.layer.shadowColor = #colorLiteral(red: 0.05542261899, green: 0.004148194566, blue: 0.1240254864, alpha: 1)
        self.arButton.layer.shadowRadius = 0.0
        self.arButton.layer.shadowOffset = CGSize(
            width: self.arButton.frame.width/15,
            height: self.arButton.frame.height/15)
        
        self.shopButton.layer.shadowOpacity = 1.0
        self.shopButton.layer.shadowColor = #colorLiteral(red: 0.05542261899, green: 0.004148194566, blue: 0.1240254864, alpha: 1)
        self.shopButton.layer.shadowRadius = 0.0
        self.shopButton.layer.shadowOffset = CGSize(
            width: self.shopButton.frame.width/15,
            height: self.shopButton.frame.height/15)
        
        self.statisticButton.layer.shadowOpacity = 1.0
        self.statisticButton.layer.shadowColor = #colorLiteral(red: 0.05542261899, green: 0.004148194566, blue: 0.1240254864, alpha: 1)
        self.statisticButton.layer.shadowRadius = 0.0
        self.statisticButton.layer.shadowOffset = CGSize(
            width: self.statisticButton.frame.width/15,
            height: self.statisticButton.frame.height/15)
        
        if !UserProgress.wasAppAlreadyLaunched {
            GameCurrency.userMoney = 10_000
            UserSettings.musicVolumeValue = 1.0
            UserSettings.musicVolumeValue = 1.0
            UserProgress.wasAppAlreadyLaunched = true
        }
        // подгатавливаем, чтобы можно было проигрывать кастомные "тактильные ощущения"
        HapticManager.prepare()
        // чтобы можно было проигрывать звуки и музыку в игре
//        SoundManager.setup()
        // подгадавливаем скины для игровых объектов 2д части (чтобы потом много раз не загружать их)
        Ball2D.initializeBallSkins()
        Particle2D.initializeParticleSkins()
        Paddle2D.initializePaddleSkins()
        
        Paddle3D.initializePaddleSkins()
        Particle3D.initializeParticleSkins()
        Ball3D.initializeBallSkins()
        
        SoundManager.playMenuAmbientMusic()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.menuScene?.pauseMenu()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.menuScene?.unpauseMenu()
        
        DispatchQueue.main.async {
            self.userMoney.text = GameCurrency.updateUserMoneyLabel()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return []
    }
    
    @IBAction func levelsButtonPressed(_ sender: UIButton) {
        // ставим на паузу сцену(для производительности)
//        self.menuScene?.pauseMenu()
        // переходим к игровому контроллеру
//        self.performSegue(withIdentifier: "FromMenuToLevelsMenu", sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func touchDownOnARMenuButton(_ sender: UIButton) {
        HapticManager.collisionVibrate(with: .medium, 20.0)
    }
    
    @IBAction func toARMenuButtonPressed(_ sender: UIButton) {
//        self.menuScene?.pauseMenu()
        self.performSegue(withIdentifier: "FromMenuToARMenu", sender: self)
    }
    
    @IBAction func unwindToMenu(_ sender: UIStoryboardSegue) {
//        self.menuScene?.unpauseMenu()
    }
}
