//
//  SettingsViewController.swift
//  Breakout
//
//  Created by Out East on 31.12.2022.
//

import UIKit
import RiveRuntime
class SettingsViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var soundsLabel: UILabel!
    
    
    @IBOutlet weak var musicSlider: CosmicStyleSlider!
    @IBOutlet weak var soundsSlider: UISlider!
    
    private let riveView = RiveView()
    private let riveViewModel = RiveViewModel(fileName: "backgroundstars")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.riveViewModel.setView(riveView)
        self.riveViewModel.play(loop: .loop)
        self.riveViewModel.alignment = .center
        self.riveViewModel.fit = .fill
        
        self.view.addSubview(self.riveView)
        self.view.sendSubviewToBack(self.riveView)
        
        self.riveView.frame = self.view.bounds
        self.riveView.center = self.view.center
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    @IBAction func musicSliderValueChanged(_ sender: UISlider) {
//    }
    
    @IBAction func soundsSliderValueChanged(_ sender: Any) {
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
