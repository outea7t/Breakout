//
//  SettingsViewController.swift
//  Breakout
//
//  Created by Out East on 31.12.2022.
//

import UIKit
import RiveRuntime
import SpriteKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var soundsLabel: UILabel!
    
    
    @IBOutlet weak var musicSlider: CosmicSlider!
    @IBOutlet weak var soundsSlider: CosmicSlider!
    
    private let riveView = RiveView()
    private let riveViewModel = RiveViewModel(fileName: "backgroundstars")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let view = self.view.viewWithTag(1) as? SKView {
            view.backgroundColor = .clear
            
            let scene = SettingsScene(size: view.bounds.size)
            scene.musicLabelPosition = self.musicLabel.frame.origin
            scene.soundsLabelPosition = self.soundsLabel.frame.origin
            scene.scaleMode = .fill
            view.presentScene(scene)
            
        }
        self.riveViewModel.setView(riveView)
        self.riveViewModel.play(loop: .loop)
        self.riveViewModel.alignment = .center
        self.riveViewModel.fit = .fill
        
        self.view.addSubview(self.riveView)
        self.view.sendSubviewToBack(self.riveView)
        
        self.riveView.frame = self.view.bounds
        self.riveView.center = self.view.center
        
        self.musicSlider.value = UserSettings.musicVolumeValue
        self.soundsSlider.value = UserSettings.soundsVolumeValue
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func musicSliderValueChanged(_ sender: CosmicSlider) {
        UserSettings.musicVolumeValue = sender.value
    }
    @IBAction func soundsSliderValueChanged(_ sender: CosmicSlider) {
        UserSettings.soundsVolumeValue = sender.value
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
