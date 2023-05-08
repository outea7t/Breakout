//
//  StatisticsViewController.swift
//  Breakout
//
//  Created by Out East on 07.05.2023.
//

import UIKit
/// меню со статистикой пользователя в игре
/// также планируется сделать соединение с gameCenter для создания leaderboard в игре
class StatisticsViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var _1Divider: UIView!
    @IBOutlet weak var totalStars: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    
    @IBOutlet weak var _2Divider: UIView!
    @IBOutlet weak var maxStreak: UILabel!
    @IBOutlet weak var maxAvailableLevel: UILabel!
    
    @IBOutlet weak var _3Divider: UIView!
    @IBOutlet weak var timeSpent: UILabel!
    
    @IBOutlet weak var _4Divider: UIView!
    @IBOutlet weak var buyed2DSkins: UILabel!
    @IBOutlet weak var buyed3DSkins: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.totalStars.text = "total stars: \(UserProgress.totalStars)"
        self.totalScore.text = "total score: \(UserProgress.totalScore)"
        
        self.maxStreak.text = "max streak: 0"
        self.maxAvailableLevel.text = "max available level: \(UserProgress._2DmaxAvailableLevelID)"
        
        self.timeSpent.text = "time spent: \(UserProgress.timeSpentString)"
        
        self.buyed2DSkins.text = "buyed 2d skins: \(UserProgress._2DbuyedSkins)"
        self.buyed3DSkins.text = "buyed 3d skins: \(UserProgress._3DbuyedSkins)"
        
        self.setDivider(self._1Divider)
        self.setDivider(self._2Divider)
        self.setDivider(self._3Divider)
        self.setDivider(self._4Divider)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    private func setDivider(_ divider: UIView) {
        divider.layer.cornerRadius = 3
    }
}
