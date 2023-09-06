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
    @IBOutlet weak var rhombusLabel: UIImageView!
    
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
//            view.showsPhysics = true
            // сцена меню, чтобы можно было ей управлять
            self.menuScene = scene
        
            // настраиваем некоторые дебаг опции
            view.ignoresSiblingOrder = true
//            view.showsFPS = true
//            view.showsNodeCount = true
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
        // подгадавливаем скины для игровых объектов 2д части (чтобы потом много раз не загружать их)
        Ball2D.initializeBallSkins()
        Particle2D.initializeParticleSkins()
        Paddle2D.initializePaddleSkins()
        Brick2D.initializeLevelColorSchemes()
        
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
        
        self.setConstraintsForARMenuButton()
        self.setConstraintsForStatisticButton()
        self.setConstraintsForShopButton()
        self.setConstraintsForRhombusLabel()
        self.setConstraintsForUserMoneyLabel()
        self.setConstraintsForSettings()
        self.setConstraintsForLevelsButton()
  
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
    
    private func setConstraintsForLevelsButton() {
        self.levelsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let widthScaleConstant: CGFloat = 280/390 * self.view.frame.width
        let heightScaleConstant: CGFloat = widthScaleConstant/3.5
        
        var levelsButtonConstraints = [NSLayoutConstraint]()
        
        levelsButtonConstraints.append(self.levelsButton.widthAnchor.constraint(equalToConstant: widthScaleConstant))
        levelsButtonConstraints.append(self.levelsButton.heightAnchor.constraint(equalToConstant: heightScaleConstant))
        levelsButtonConstraints.append(self.levelsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor))
        levelsButtonConstraints.append(self.levelsButton.bottomAnchor.constraint(equalTo: self.settingsButton.topAnchor, constant: -20))
        
        NSLayoutConstraint.activate(levelsButtonConstraints)
    }
    
    private func setConstraintsForSettings() {
        self.settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let widthScaleConstant: CGFloat = 280/390 * self.view.frame.width
        let heightScaleConstant: CGFloat = widthScaleConstant/3.5
        
        var settingsButtonConstraints = [NSLayoutConstraint]()
        
        settingsButtonConstraints.append(self.settingsButton.widthAnchor.constraint(equalToConstant: widthScaleConstant))
        settingsButtonConstraints.append(self.settingsButton.heightAnchor.constraint(equalToConstant: heightScaleConstant))
        settingsButtonConstraints.append(self.settingsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor))
        settingsButtonConstraints.append(self.settingsButton.bottomAnchor.constraint(equalTo: self.statisticButton.topAnchor, constant: -40))
        
        NSLayoutConstraint.activate(settingsButtonConstraints)
    }
    
    private func setConstraintsForStatisticButton() {
        self.statisticButton.translatesAutoresizingMaskIntoConstraints = false
        
        var statisticButtonScaleConstant: CGFloat = 100/844
        
        var statisticButtonConstraints = [NSLayoutConstraint]()
        
        statisticButtonConstraints.append(self.statisticButton.widthAnchor.constraint(equalToConstant: statisticButtonScaleConstant * self.view.frame.height))
        statisticButtonConstraints.append(self.statisticButton.heightAnchor.constraint(equalToConstant: statisticButtonScaleConstant * self.view.frame.height))
        statisticButtonConstraints.append(self.statisticButton.centerXAnchor.constraint(equalTo: self.arButton.centerXAnchor))
        statisticButtonConstraints.append(self.statisticButton.bottomAnchor.constraint(equalTo: self.arButton.topAnchor, constant: -10))
        
        NSLayoutConstraint.activate(statisticButtonConstraints)
    }
    
    private func setConstraintsForARMenuButton() {
        self.arButton.translatesAutoresizingMaskIntoConstraints = false
        
        var arButtonScaleConstant: CGFloat = 125/844
        
        var arButtonConstraints = [NSLayoutConstraint]()
        
        arButtonConstraints.append(self.arButton.widthAnchor.constraint(equalToConstant: arButtonScaleConstant * self.view.frame.size.height))
        arButtonConstraints.append(self.arButton.heightAnchor.constraint(equalToConstant: arButtonScaleConstant * self.view.frame.size.height))
        arButtonConstraints.append(self.arButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 7))
        arButtonConstraints.append(self.arButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20))
        
        NSLayoutConstraint.activate(arButtonConstraints)
    }
    
    private func setConstraintsForShopButton() {
        self.shopButton.translatesAutoresizingMaskIntoConstraints = false
        
        let shopButtonScaleConstant: CGFloat = 125/844
        
        var shopButtonConstraints = [NSLayoutConstraint]()
        
        shopButtonConstraints.append(self.shopButton.widthAnchor.constraint(equalToConstant: shopButtonScaleConstant * self.view.frame.size.height))
        shopButtonConstraints.append(self.shopButton.heightAnchor.constraint(equalToConstant: shopButtonScaleConstant * self.view.frame.size.height))
        shopButtonConstraints.append(self.shopButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -7))
        shopButtonConstraints.append(self.shopButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20))
        
        NSLayoutConstraint.activate(shopButtonConstraints)
    }
    
    private func setConstraintsForUserMoneyLabel() {
        self.userMoney.translatesAutoresizingMaskIntoConstraints = false
        
        self.userMoney.adjustsFontSizeToFitWidth = true
        
        let width: CGFloat = 90
        let height:CGFloat = 50
        
        var userMoneyLabelConstraints = [NSLayoutConstraint]()
        
        userMoneyLabelConstraints.append(self.userMoney.widthAnchor.constraint(equalToConstant: width))
        userMoneyLabelConstraints.append(self.userMoney.heightAnchor.constraint(equalToConstant: height))
        userMoneyLabelConstraints.append(self.userMoney.trailingAnchor.constraint(equalTo: self.rhombusLabel.leadingAnchor))
        userMoneyLabelConstraints.append(self.userMoney.centerYAnchor.constraint(equalTo: self.rhombusLabel.centerYAnchor))
        
        NSLayoutConstraint.activate(userMoneyLabelConstraints)
    }
    
    private func setConstraintsForRhombusLabel() {
        self.rhombusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let rhombusLabelScaleConstant: CGFloat = 40/844
        
        var rhombusLabelConstraints = [NSLayoutConstraint]()
        
        rhombusLabelConstraints.append(self.rhombusLabel.widthAnchor.constraint(equalToConstant: rhombusLabelScaleConstant * self.view.frame.height))
        rhombusLabelConstraints.append(self.rhombusLabel.heightAnchor.constraint(equalToConstant: rhombusLabelScaleConstant * self.view.frame.height))
        rhombusLabelConstraints.append(self.rhombusLabel.trailingAnchor.constraint(equalTo: self.shopButton.trailingAnchor))
        rhombusLabelConstraints.append(self.rhombusLabel.bottomAnchor.constraint(equalTo: self.shopButton.topAnchor, constant: -5))
        
        NSLayoutConstraint.activate(rhombusLabelConstraints)
    }
}
