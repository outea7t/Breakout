//
//  MenuViewController.swift
//  Test3D_AR_Game_PVMASLOV
//
//  Created by Out East on 11.11.2022.
//

import UIKit
import AVFoundation
import SceneKit
import ARKit
import RiveRuntime

class ARMenuViewController: UIViewController, ARSCNViewDelegate {
    
    // сцена для анимации с интерактивными буквами
    weak var arMenuScene: ARMenuScene?
    
    @IBOutlet weak var levelsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var toMainMenuButton: UIButton!
    @IBOutlet weak var userMoney: UILabel!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var rhombusLabel: UIImageView!
    
    // переменные для захвата видео с задней камеры телефона
    var session: AVCaptureSession?
    private let output = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    // фоновая анимация
    private let backgroundView = RiveView()
    private let backgroundViewModel = RiveViewModel(fileName: "arbackground")
    
    deinit {
        print("ARMenuViewController DEINITIALIZED")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // настраиваем riveView
        self.backgroundViewModel.setView(self.backgroundView)
        self.backgroundViewModel.play(animationName: "AmbientAnimation", loop: .loop)
        
        self.backgroundViewModel.alignment = .center
        self.backgroundViewModel.fit = .fill
        
        self.view.addSubview(self.backgroundView)
        self.view.sendSubviewToBack(self.backgroundView)
        self.view.sendSubviewToBack(self.blurView)
        self.view.sendSubviewToBack(self.cameraView)
        
        self.backgroundView.frame = self.view.bounds
        self.backgroundView.center = self.view.center
        
        if let view = self.view.viewWithTag(1) as? SKView {
            view.backgroundColor = .clear
            let scene = ARMenuScene(size: self.view.bounds.size)
            self.arMenuScene = scene
            self.arMenuScene?.scaleMode = .aspectFill
            if let arMenuScene = self.arMenuScene {
                view.presentScene(arMenuScene)
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
        
        // настраиваем тени этих кнопок
        self.levelsButton.layer.shadowOpacity = 1.0
        self.levelsButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.levelsButton.layer.shadowRadius = 0
        self.levelsButton.layer.shadowOffset = CGSize(width: self.levelsButton.frame.width/30,
                                                      height: self.levelsButton.frame.height/10)
        
        self.settingsButton.layer.shadowOpacity = 1.0
        self.settingsButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.settingsButton.layer.shadowRadius = 0
        self.settingsButton.layer.shadowOffset = CGSize(width: self.settingsButton.frame.width/30,
                                                        height: self.settingsButton.frame.height/10)
                                                     
        
        self.toMainMenuButton.layer.shadowOpacity = 1.0
        self.toMainMenuButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.08817758411, blue: 0.04436858743, alpha: 1)
        self.toMainMenuButton.layer.shadowRadius = 0
        self.toMainMenuButton.layer.shadowOffset = CGSize(width: self.toMainMenuButton.frame.width/12,
                                                          height: self.toMainMenuButton.frame.height/16)
        
        self.shopButton.layer.shadowOpacity = 1.0
        self.shopButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.08817758411, blue: 0.04436858743, alpha: 1)
        self.shopButton.layer.shadowRadius = 0
        self.shopButton.layer.shadowOffset = CGSize(width: self.shopButton.frame.width/15,
                                                    height: self.shopButton.frame.height/15)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedForeground() {
        self.checkCameraPermission()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // выводим изображение с камеры на экран телефона
        if let cameraView = self.view.viewWithTag(2) {
            self.previewLayer.frame = cameraView.bounds
            self.previewLayer.position = cameraView.center
            cameraView.layer.addSublayer(previewLayer)
        }
        
        self.checkCameraPermission()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.arMenuScene?.unpauseScene()
        
        self.setConstraintsForToMainMenuButton()
        self.setConstraintsForShopButton()
        self.setConstraintsForRhombusLabel()
        self.setConstraintsForMoneyLabel()
        self.setConstraintsForSettingsButton()
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
    @IBAction func unwindToARMenu(_ sender: UIStoryboardSegue) {
        self.arMenuScene?.unpauseScene()
        let backgroundQueue = DispatchQueue(label: "background_queue",qos: .background)
        backgroundQueue.async {
            self.session?.startRunning()
        }
        
    }
    
    @IBAction func levelsButtonPressed(_ sender: Any) {
        self.arMenuScene?.pauseScene()
        self.performSegue(withIdentifier: "FromARMenuToLevelsARMenu", sender: self)
        
        self.session?.stopRunning()
    }
    
    @IBAction func shopButtonPressed(_ sender: UIButton) {
        self.arMenuScene?.pauseScene()
    }
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func mainMenuButtonTouchDown(_ sender: UIButton) {
        HapticManager.collisionVibrate(with: .medium, 20.0)
    }
    
    @IBAction func backToMenuButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    // спрашиваем доступ к камере телефона
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                self.requestAccess()
            case .denied, .restricted:
                showCameraRestrictedAlert()
                showCameraRestrictedAlert()
            case .authorized:
                self.setUpCamera()
            @unknown default:
                break
            }
    }
    private func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
            guard granted else {
                return
            }
            DispatchQueue.main.async {
                self?.setUpCamera()
            }
        }
    }
    private func showCameraRestrictedAlert() {
        let alert = UIAlertController(title: "Camera Access Restricted",
                                      message: "Camera access is restricted. Please enable camera access in Settings to use this game in AR.",
                                      preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL, completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            HapticManager.notificationVibrate(for: .error)
            self.dismiss(animated: true)
        }
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    // настраиваем камеру
    private func setUpCamera() {
        // сессия
        let session = AVCaptureSession()
        // находим устройство записи видео по умолчанию
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                // видео инпут добавляем к сессии
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(self.output) {
                    session.addOutput(output)
                }

                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                let backgroundQueue = DispatchQueue(label: "background_queue", qos: .background)
                backgroundQueue.async {
                    session.startRunning()
                }
                
                self.session = session
            } catch {
                print(error)
            }
        }
    }
    
    private func setConstraintsForToMainMenuButton() {
        self.toMainMenuButton.translatesAutoresizingMaskIntoConstraints = false
        
        var toMainMenuButtonScaleConstant: CGFloat = 125/844
        
        var toMainMenuButtonConstraints = [NSLayoutConstraint]()
        
        toMainMenuButtonConstraints.append(self.toMainMenuButton.widthAnchor.constraint(equalToConstant: toMainMenuButtonScaleConstant * self.view.frame.size.height))
        toMainMenuButtonConstraints.append(self.toMainMenuButton.heightAnchor.constraint(equalToConstant: toMainMenuButtonScaleConstant * self.view.frame.size.height))
        toMainMenuButtonConstraints.append(self.toMainMenuButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 7))
        toMainMenuButtonConstraints.append(self.toMainMenuButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20))
        
        NSLayoutConstraint.activate(toMainMenuButtonConstraints)
    }
    
    private func setConstraintsForSettingsButton() {
        self.settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let widthScaleConstant: CGFloat = 280/390 * self.view.frame.width
        let heightScaleConstant: CGFloat = widthScaleConstant/3.5
        
        let statisticButtonScaleConstant: CGFloat = 100/844 * self.view.frame.height + 10
        
        var settingsButtonConstraints = [NSLayoutConstraint]()
        
        settingsButtonConstraints.append(self.settingsButton.widthAnchor.constraint(equalToConstant: widthScaleConstant))
        settingsButtonConstraints.append(self.settingsButton.heightAnchor.constraint(equalToConstant: heightScaleConstant))
        settingsButtonConstraints.append(self.settingsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor))
        settingsButtonConstraints.append(self.settingsButton.bottomAnchor.constraint(equalTo: self.toMainMenuButton.topAnchor, constant: -40 - statisticButtonScaleConstant))
        
        NSLayoutConstraint.activate(settingsButtonConstraints)

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
    
    private func setConstraintsForMoneyLabel() {
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
}

