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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setConstraintsForBackButton()
        self.setConstraintsForMusicLabel()
        self.setConstraintsForMusicSlider()
        self.setConstraintsForSoundsLabel()
        self.setConstraintsForSoundsSlider()
        
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
    
    private func setConstraintsForBackButton() {
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        
        let backButtonSizeConstant: CGFloat = 80/390
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.backButton.widthAnchor.constraint(equalToConstant: backButtonSizeConstant * self.view.frame.width))
        constraints.append(self.backButton.heightAnchor.constraint(equalToConstant: backButtonSizeConstant * self.view.frame.width))
        constraints.append(self.backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.safeAreaInsets.top + 40))
        constraints.append(self.backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setConstraintsForSettingsLabel() {
        self.settingsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstant: CGFloat = 65/844
        let widthConstant: CGFloat = 347/390
        
        self.settingsLabel.adjustsFontSizeToFitWidth = true
        
        var constraints = [NSLayoutConstraint]()

        constraints.append(self.settingsLabel.topAnchor.constraint(equalTo: self.backButton.bottomAnchor, constant: 25))
        constraints.append(self.settingsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor))
        constraints.append(self.settingsLabel.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.settingsLabel.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setConstraintsForMusicLabel() {
        self.musicLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.musicLabel.adjustsFontSizeToFitWidth = true
        
        let heightConstant: CGFloat = 50/844
        let widthConstant: CGFloat = 174/390
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.musicLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30))
        constraints.append(self.musicLabel.topAnchor.constraint(equalTo: self.settingsLabel.bottomAnchor, constant: 80))
        constraints.append(self.musicLabel.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.musicLabel.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setConstraintsForMusicSlider() {
        self.musicSlider.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstant: CGFloat = 30/844
    
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.musicSlider.topAnchor.constraint(equalTo: self.musicLabel.bottomAnchor, constant: 40))
        constraints.append(self.musicSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40))
        constraints.append(self.musicSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40))
        constraints.append(self.musicSlider.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setConstraintsForSoundsLabel() {
        self.soundsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.soundsLabel.adjustsFontSizeToFitWidth = true
        
        let heightConstant: CGFloat = 50/844
        let widthConstant: CGFloat = 215/390
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.soundsLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30))
        constraints.append(self.soundsLabel.topAnchor.constraint(equalTo: self.musicSlider.bottomAnchor, constant: 50))
        constraints.append(self.soundsLabel.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.soundsLabel.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setConstraintsForSoundsSlider() {
        self.soundsSlider.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstant: CGFloat = 30/844
    
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.soundsSlider.topAnchor.constraint(equalTo: self.soundsLabel.bottomAnchor, constant: 40))
        constraints.append(self.soundsSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40))
        constraints.append(self.soundsSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40))
        constraints.append(self.soundsSlider.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
