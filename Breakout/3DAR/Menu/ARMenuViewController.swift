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
        
        
        self.backgroundViewModel.alignment = .topLeft
        self.backgroundViewModel.fit = .fill
        self.view.addSubview(self.backgroundView)
        self.view.sendSubviewToBack(self.backgroundView)
        self.view.sendSubviewToBack(self.blurView)
        self.view.sendSubviewToBack(self.cameraView)
        
        self.backgroundView.frame = self.view.bounds
        self.backgroundView.center = self.view.center
        
        if let view = self.view.viewWithTag(1) as? SKView {
            view.backgroundColor = .clear
            let scene = ARMenuScene(size: view.bounds.size)
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
        print("CHECKING STATUS")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
            print("NOT DETERMIND")
                self.requestAccess()
            case .denied, .restricted:
            print("DENIED OR RESTRICTED")
                showCameraRestrictedAlert()
                showCameraRestrictedAlert()
            case .authorized:
            print("AUTHORIZED")
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
}

