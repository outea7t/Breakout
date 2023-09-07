//
//  StatisticsViewController.swift
//  Breakout
//
//  Created by Out East on 07.05.2023.
//

import UIKit
import RiveRuntime
/// меню со статистикой пользователя в игре
/// также планируется сделать соединение с gameCenter для создания leaderboard в игре
class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var statsLabel: UILabel!
    
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
    @IBOutlet weak var skinsImageView: UIImageView!
    
    @IBOutlet weak var starsImageView: UIImageView!
    let riveView = RiveView()
    let riveViewModel = RiveViewModel(fileName: "backgroundstars")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        riveViewModel.setView(riveView)
        riveViewModel.play(loop: .loop)
        
        riveViewModel.alignment = .center
        riveViewModel.fit = .fill
        self.view.addSubview(riveView)
        self.view.sendSubviewToBack(riveView)
        
        riveView.frame = self.view.bounds
        riveView.center = self.view.center
        
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setConstraintsForBackButton()
        self.setConstraintsForSetsLabel()
        self.setConstraintsForFirstDivider()
        self.setConstraintsForTotalStars()
        self.setConstraintsForTotalScore()
        self.setConstraintsForSecondDivider()
        self.setConstraintsForMaxStreak()
        self.setConstraintsForMaxAvailableLevel()
        self.setConstraintsForThirdDivider()
        self.setConstraintsForTimeSpent()
        self.setConstraintsForFourthDivider()
        self.setConstraintsForBuyed2DSkins()
        self.setConstraintsForBuyed3DSkins()
        self.setConstraintsForStarsImage()
        self.setConstraintsForSkinsImage()
        
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
    
    private func setConstraintsForSetsLabel() {
        self.statsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstant: CGFloat = 94/844
        let widthConstant: CGFloat = 255/390
        
        self.statsLabel.adjustsFontSizeToFitWidth = true
        
        var constraints = [NSLayoutConstraint]()

        constraints.append(self.statsLabel.topAnchor.constraint(equalTo: self.backButton.bottomAnchor, constant: 25))
        constraints.append(self.statsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor))
        constraints.append(self.statsLabel.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.statsLabel.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setConstraintsForFirstDivider() {
        self._1Divider.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstant: CGFloat = 212/390
        let heightConstant: CGFloat = 2/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self._1Divider.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self._1Divider.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self._1Divider.topAnchor.constraint(equalTo: self.statsLabel.bottomAnchor, constant: 70))
        constraints.append(self._1Divider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForTotalStars() {
        self.totalStars.translatesAutoresizingMaskIntoConstraints = false
        
        self.totalStars.adjustsFontSizeToFitWidth = true
        
        let widthConstant: CGFloat = 238/390
        let heightConstant: CGFloat = 20/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.totalStars.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.totalStars.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.totalStars.topAnchor.constraint(equalTo: self._1Divider.bottomAnchor, constant: 13))
        constraints.append(self.totalStars.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForTotalScore() {
        self.totalScore.translatesAutoresizingMaskIntoConstraints = false
        
        self.totalScore.adjustsFontSizeToFitWidth = true
        
        let widthConstant: CGFloat = 238/390
        let heightConstant: CGFloat = 20/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.totalScore.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.totalScore.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.totalScore.topAnchor.constraint(equalTo: self.totalStars.bottomAnchor, constant: 12))
        constraints.append(self.totalScore.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForSecondDivider() {
        self._2Divider.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstant: CGFloat = 305/390
        let heightConstant: CGFloat = 2/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self._2Divider.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self._2Divider.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self._2Divider.topAnchor.constraint(equalTo: self.totalScore.bottomAnchor, constant: 13))
        constraints.append(self._2Divider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForMaxStreak() {
        self.maxStreak.translatesAutoresizingMaskIntoConstraints = false
        
        self.maxStreak.adjustsFontSizeToFitWidth = true
        
        let widthConstant: CGFloat = 232/390
        let heightConstant: CGFloat = 20/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.maxStreak.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.maxStreak.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.maxStreak.topAnchor.constraint(equalTo: self._2Divider.bottomAnchor, constant: 13))
        constraints.append(self.maxStreak.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForMaxAvailableLevel() {
        self.maxAvailableLevel.translatesAutoresizingMaskIntoConstraints = false
        
        self.maxAvailableLevel.adjustsFontSizeToFitWidth = true
        
        let widthConstant: CGFloat = 318/390
        let heightConstant: CGFloat = 20/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.maxAvailableLevel.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.maxAvailableLevel.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.maxAvailableLevel.topAnchor.constraint(equalTo: self.maxStreak.bottomAnchor, constant: 12))
        constraints.append(self.maxAvailableLevel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForThirdDivider() {
        self._3Divider.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstant: CGFloat = 215/390
        let heightConstant: CGFloat = 2/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self._3Divider.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self._3Divider.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self._3Divider.topAnchor.constraint(equalTo: self.maxAvailableLevel.bottomAnchor, constant: 13))
        constraints.append(self._3Divider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForTimeSpent() {
        self.timeSpent.translatesAutoresizingMaskIntoConstraints = false
        
        self.timeSpent.adjustsFontSizeToFitWidth = true
        
        let widthConstant: CGFloat = 330/390
        let heightConstant: CGFloat = 20/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.timeSpent.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.timeSpent.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.timeSpent.topAnchor.constraint(equalTo: self._3Divider.bottomAnchor, constant: 13))
        constraints.append(self.timeSpent.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForFourthDivider() {
        self._4Divider.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstant: CGFloat = 215/390
        let heightConstant: CGFloat = 2/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self._4Divider.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self._4Divider.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self._4Divider.topAnchor.constraint(equalTo: self.timeSpent.bottomAnchor, constant: 13))
        constraints.append(self._4Divider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForBuyed2DSkins() {
        self.buyed2DSkins.translatesAutoresizingMaskIntoConstraints = false
        
        self.buyed2DSkins.adjustsFontSizeToFitWidth = true
        
        let widthConstant: CGFloat = 330/390
        let heightConstant: CGFloat = 20/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.buyed2DSkins.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.buyed2DSkins.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.buyed2DSkins.topAnchor.constraint(equalTo: self._4Divider.bottomAnchor, constant: 13))
        constraints.append(self.buyed2DSkins.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForBuyed3DSkins() {
        self.buyed3DSkins.translatesAutoresizingMaskIntoConstraints = false
        
        self.buyed3DSkins.adjustsFontSizeToFitWidth = true
        
        let widthConstant: CGFloat = 318/390
        let heightConstant: CGFloat = 20/844
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.buyed3DSkins.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.buyed3DSkins.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.buyed3DSkins.topAnchor.constraint(equalTo: self.buyed2DSkins.bottomAnchor, constant: 12))
        constraints.append(self.buyed3DSkins.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForStarsImage() {
        self.starsImageView.contentMode = .scaleAspectFit
        self.starsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstant: CGFloat = 140/390
        let heightConstant: CGFloat = 75/844
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.starsImageView.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.starsImageView.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.starsImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20))
        constraints.append(self.starsImageView.topAnchor.constraint(equalTo: self._1Divider.topAnchor, constant: -10))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func setConstraintsForSkinsImage() {
        self.skinsImageView.contentMode = .scaleAspectFit
        self.skinsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstant: CGFloat = 130/390
        let heightConstant: CGFloat = 90/844
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.skinsImageView.widthAnchor.constraint(equalToConstant: widthConstant * self.view.frame.width))
        constraints.append(self.skinsImageView.heightAnchor.constraint(equalToConstant: heightConstant * self.view.frame.height))
        constraints.append(self.skinsImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20))
        constraints.append(self.skinsImageView.topAnchor.constraint(equalTo: self._4Divider.topAnchor, constant: -20))
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
