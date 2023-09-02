//
//  LevelsMenuViewColntroller2.swift
//  Breakout
//
//  Created by Out East on 28.01.2023.
//

import UIKit

class LevelsMenuViewColntroller: UIViewController {
    var levelChoosed = 1
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// верхнее меню
    @IBOutlet weak var headerTopView: UIView!
    /// кнопка возвращения в меню
    @IBOutlet weak var backToMenuButton: UIButton!
    
    
    // для анимации увеличения кнопок по мере того, как мы скролим меню
    /// все массив информации с уровнями
    private var levelsCellsData = [LevelsMenuCellData]()
    private let cellIdentifier = "LevelsMenuCollectionViewCell"
    private var cellFrameWidth = CGFloat()
    override func viewDidLoad() {
        super.viewDidLoad()
        // находим класс, который будем использовать для ячеек
        let cellClass = UINib(nibName: self.cellIdentifier, bundle: nil)
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        // настраиваем расположение ячеек в collectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        // отступы от конкретных граней
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        
        self.collectionView.collectionViewLayout = layout
        
        let availableColor = #colorLiteral(red: 0.3578048348, green: 0, blue: 0.881958127, alpha: 1)
        let unavailableColor = #colorLiteral(red: 0.2112675011, green: 0.08965469152, blue: 0.4645008445, alpha: 1)
        let shadowColor = #colorLiteral(red: 0.1314683557, green: 0.01993882656, blue: 0.3431168795, alpha: 1)
        
        for i in 1...30 {
            let stars = UserProgress._2DlevelsStars[i-1]
            var level = LevelsMenuCellData(backgroundColor: availableColor,
                                           shadowColor: shadowColor,
                                           levelNumber: i,
                                           starsCount: stars,
                                           isAvailable: false)
            if i <= UserProgress._2DmaxAvailableLevelID {
                level.isAvailable = true
            } else {
                level.isAvailable = false
                level.backgroundColor = unavailableColor
            }
            
            self.levelsCellsData.append(level)
        }
        
        // настраиваем тени и прочую косметику
        self.view.sendSubviewToBack(self.collectionView)
        
        // настраиваем верхнее меню
        self.headerTopView.layer.cornerRadius = 20.0
        self.headerTopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        // настраиваем тень
        self.headerTopView.layer.shadowOpacity = 1.0
        self.headerTopView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.headerTopView.layer.shadowOffset = CGSize(width: 0.0,
                                                       height: 15.0)
        self.headerTopView.layer.shadowRadius = 8
        // кнопка возврата в меню
        self.backToMenuButton.layer.cornerRadius = 10
        
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
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameViewController = segue.destination as? GameViewController {
            gameViewController.levelChoosed = self.levelChoosed
        }
    }
   
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    /// анимация измнения размера кнопок, когда мы листаем
    /// чем ближе кнопка к центру видимого экрана, тем больше ее размер
    private func scaleAllButtonsWhileScrolling(actualViewCenter: CGFloat) {
        for i in 0..<self.levelsCellsData.count {
            let indexPath = IndexPath(item: i, section: 0)
            let cell = self.collectionView.cellForItem(at: indexPath)
            
            if let cell = cell {
                let buttonYCenterOffset = abs(cell.layer.position.y - actualViewCenter)
                var percentage = (1 - buttonYCenterOffset/(self.view.bounds.height/2.0))
                
                // мы не хотим, чтобы кнопок прямо совсе не было видно
                // поэтому задаем их максимальное уменьшение
                if percentage < 0.5 {
                    percentage = 0.5
                }
                // еще сильнее увеличиваем, центральные элементы были еще больше
                percentage += 0.15
                cell.transform = CGAffineTransform.identity.scaledBy(x: percentage, y: percentage)
            }
        }
    }
}

extension LevelsMenuViewColntroller: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        // координаты центра телефона
        let centerY = yOffset + (self.view.bounds.height - self.headerTopView.bounds.height)/2.0
        // изменяем размер кнопок
        self.scaleAllButtonsWhileScrolling(actualViewCenter: centerY)
    }
}

// сколько чего и как создавать
extension LevelsMenuViewColntroller: UICollectionViewDataSource {
    // сколько ячеек создавать
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.levelsCellsData.count
    }
    // количество элементов в section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // какие ячейки создавать
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! LevelsMenuCollectionViewCell
        
        cell.setup(with: self.levelsCellsData[indexPath.item], cellFrameWidth: self.cellFrameWidth)
        return cell
        
    }
}
// как располагать ячейки в collectionView
extension LevelsMenuViewColntroller: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.width/2.5,
                          height: self.view.frame.width/2.5)
        self.cellFrameWidth = size.width
        return size
    }
}
// обработка нажатий
extension LevelsMenuViewColntroller: UICollectionViewDelegate {
    // активируется, когда мы выбираем какой-то уже купленный скин
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? LevelsMenuCollectionViewCell else {
            return
        }
        if cell.levelIndex <= UserProgress._2DmaxAvailableLevelID {
            self.levelChoosed = cell.levelIndex
            // небольшая вибрация, уведомляющая пользователя о начале игры
            HapticManager.collisionVibrate(with: .rigid, 1.0)
            
            SoundManager.stopMenuAmbientMusic()
            SoundManager.playGameAmbientMusic()
            
            
            self.performSegue(withIdentifier: GameSegue.levelsMenuToGame.rawValue, sender: self)
            
        } else {
            HapticManager.notificationVibrate(for: .error)
        }

    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    }
}

