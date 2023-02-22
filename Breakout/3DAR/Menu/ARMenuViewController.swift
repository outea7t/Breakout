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


class ARMenuViewController: UIViewController, ARSCNViewDelegate {
    
    // сцена для анимации с интерактивными буквами
    weak var arMenuScene: ARMenuScene?
    
    @IBOutlet weak var levelsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var toMainMenuButton: UIButton!
    
    // переменные для захвата видео с задней камеры телефона
    var session: AVCaptureSession?
    private let output = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    
    deinit {
        print("ARMenuViewController DEINITIALIZED")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        
        // делаем кнопки округлее
        self.levelsButton.layer.cornerRadius = self.levelsButton.frame.width / 10.0
        self.settingsButton.layer.cornerRadius = self.settingsButton.frame.width / 10.0
        // настраиваем тени этих кнопок
        self.levelsButton.layer.shadowOpacity = 1.0
        self.levelsButton.layer.shadowColor = #colorLiteral(red: 0.003220230108, green: 0.1214692518, blue: 0.5943663716, alpha: 1)
        self.levelsButton.layer.shadowRadius = 0
        self.levelsButton.layer.shadowOffset = CGSize(width: self.levelsButton.frame.width/30,
                                                      height: self.levelsButton.frame.width/20)
        
        self.settingsButton.layer.shadowOpacity = 1.0
        self.settingsButton.layer.shadowColor = #colorLiteral(red: 0.005399688613, green: 0.1200461462, blue: 0.5884372592, alpha: 1)
        self.settingsButton.layer.shadowRadius = 0
        self.settingsButton.layer.shadowOffset = CGSize(width: self.settingsButton.frame.width/30,
                                                        height: self.settingsButton.frame.width/20)
                                                     
        
        self.toMainMenuButton.layer.shadowOpacity = 1.0
        self.toMainMenuButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.5084269643, blue: 0, alpha: 1)
        self.toMainMenuButton.layer.shadowRadius = 0
        self.toMainMenuButton.layer.shadowOffset = CGSize(width: self.toMainMenuButton.frame.width/12,
                                                          height: self.toMainMenuButton.frame.height/16)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // выводим изображение с камеры на экран телефона
        if let cameraView = self.view.viewWithTag(2) {
            self.previewLayer.frame = cameraView.bounds
            self.previewLayer.position = cameraView.center
            cameraView.layer.addSublayer(previewLayer)
        }
       
        checkCameraPermission()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
            case .restricted:
                self.requestAccess()
            case .denied:
                self.requestAccess()
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

