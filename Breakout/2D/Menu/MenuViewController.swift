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
    
    @IBOutlet weak var arButton: UIButton!
    // количество денег игрока
    @IBOutlet weak var amountOfMoney: UILabel!
    // задний фон из райва
    let backgroundView = RiveView()
    let backgroundViewModel = RiveViewModel(fileName: "background")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // настраиваем riveView
        self.backgroundViewModel.setView(self.backgroundView)
        self.backgroundViewModel.play(animationName: "backAnimation", loop: .loop)
        
        
        self.view.addSubview(self.backgroundView)
        self.view.sendSubviewToBack(self.backgroundView)
        
        self.backgroundView.frame = self.view.bounds
        self.backgroundView.center = self.view.center
        
        
        
        
        
//        let image = UIImage(named: "Main.png")!
//        let imageView = UIImageView(frame: self.view.bounds)
//
//        imageView.image = image
//        imageView.frame.size = CGSize(width: imageView.frame.width * 1.05,
//                                      height: imageView.frame.height * 1.05)
//        imageView.contentMode = .scaleAspectFit
//        imageView.center = self.view.center
        
        
//        self.view.addSubview(imageView)
//        self.view.sendSubviewToBack(imageView)
        
        if let view = self.view.viewWithTag(1) as? SKView {
            view.backgroundColor = .clear
            let scene = MenuScene(size: view.bounds.size)
            scene.backgroundColor = .clear
            scene.scaleMode = .aspectFill // чтобы идеально подошли размеры сцены под view
            
            
            view.presentScene(scene)
            view.ignoresSiblingOrder = false
            view.showsFPS = true // показываем кадры в секунды
            view.showsNodeCount = true // количество nodes
            view.showsPhysics = true
            // сцена меню, чтобы можно было ей управлять
            self.menuScene = scene
        
            // настраиваем некоторые дебаг опции
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        
        // настраиваем кнопки (чтобы были красивее, однако я все равно хочу их в райве потом еще более красивыми сделать, так что ххз зачем я этим сейчас занимаюсь)
        
//        let buttonRiveView = RiveView()
//        let buttonRiveViewModel = RiveViewModel(fileName: "button")
//
//        buttonRiveViewModel.setView(buttonRiveView)
//        buttonRiveViewModel.play(loop: .loop)
//
//        self.levelsButton.addSubview(buttonRiveView)
//        self.levelsButton.sendSubviewToBack(buttonRiveView)
//        buttonRiveView.frame = self.levelsButton.bounds
//        buttonRiveView.center = self.levelsButton.center
//
//        self.levelsButton.contentMode = .scaleToFill
        
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
        
        // подгатавливаем, чтобы можно было проигрывать кастомные анимации
        
        
        HapticManager.prepare()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.menuScene?.pauseMenu()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.menuScene?.unpauseMenu()
        
        self.amountOfMoney.text = "\(GameCurrency.userMoney)"
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
        self.menuScene?.pauseMenu()
        
        // переходим к игровому контроллеру
        self.performSegue(withIdentifier: "FromMenuToLevelsMenu", sender: self)
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
        self.menuScene?.unpauseMenu()
    }
}
