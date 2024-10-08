//
//  ShopBallTexturesViewController.swift
//  Breakout
//
//  Created by Out East on 09.01.2023.
//

import UIKit

class ShopBallTexturesViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerTopView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userMoneyLabel: UILabel!
    
    var ballCellData = [ShopCellData]()
    private let cellIdentifier = "ShopCollectionViewCell"
    private var selectedCellIndexPath = IndexPath() {
        willSet {
            if newValue != selectedCellIndexPath {
                let unselectedCell = self.collectionView.cellForItem(at: selectedCellIndexPath) as? ShopCollectionViewCell
                unselectedCell?.wasUnselected(isBuyed: true)
                UserCustomization.ballSkinIndex = newValue.item
            }
        }
    }
    
    private let unselectedColor = #colorLiteral(red: 0.05882352941, green: 0.01568627451, blue: 0.1176470588, alpha: 1)
    private let buyedColor = #colorLiteral(red: 0.3411764706, green: 0.1490196078, blue: 0.5843137255, alpha: 0.8)
    private let selectedColor = #colorLiteral(red: 0.2941176471, green: 0.09019607843, blue: 0.8823529412, alpha: 0.8)
    
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
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        // отступы от конкретных граней
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 10, right: 30)
        
        
        self.collectionView.collectionViewLayout = layout
        
        // настраиваем информацию о ячейках
        let image1 = UIImage(named: "Ball-1")!
        let image2 = UIImage(named: "Ball-2")!
        let image3 = UIImage(named: "Ball-3")!
        let image4 = UIImage(named: "Ball-4")!
        let image5 = UIImage(named: "Ball-5")!
        let image6 = UIImage(named: "Ball-6")!
        
        let color = self.unselectedColor
        self.ballCellData = [ShopCellData(image: image1, price: 10, color: color, id: 0),
                             ShopCellData(image: image2, price: 20, color: color, id: 1),
                             ShopCellData(image: image3, price: 30, color: color, id: 2),
                             ShopCellData(image: image4, price: 40, color: color, id: 3),
                             ShopCellData(image: image5, price: 50, color: color, id: 4),
                             ShopCellData(image: image6, price: 60, color: color, id: 5),
                             ShopCellData(image: UIImage(), price: 70, color: color, id: 6),
        ]
        // добавляем GR для распознавания жеста покупки ячейки
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        longPressGesture.minimumPressDuration = 0.4
        longPressGesture.numberOfTouchesRequired = 1
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        // скргуляем углы кнопки
        self.backButton.layer.cornerRadius = 10
        super.viewDidLoad()
        // настраиваем верхнее меню
        self.headerTopView.layer.cornerRadius = 20.0
        self.headerTopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        // настраиваем тень
        self.headerTopView.layer.shadowOpacity = 1.0
        self.headerTopView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.headerTopView.layer.shadowOffset = CGSize(width: 0.0,
                                                       height: 15.0)
        self.headerTopView.layer.shadowRadius = 8
        
        // для того, чтобы была видна тень
        self.view.sendSubviewToBack(self.collectionView)
        print("BALLTEXTURES")
        
        if !UserCustomization.buyedBallSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization.ballSkinIndex, section: 0)
        }
        
        
    }
    
    @objc func longPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: self.collectionView)
        guard let targetIndexPath = self.collectionView.indexPathForItem(at: gestureLocation) else {
            return
        }
        
        switch gesture.state {
        case .began:
            print("almost began for - \(targetIndexPath.item)")
            
            
            if let cell = self.collectionView.cellForItem(at: targetIndexPath) as? ShopCollectionViewCell {
                
                if !self.doesBuyedItemsContains(item: targetIndexPath) &&
                    GameCurrency.userMoney >= cell.price {
                    self.selectedCellIndexPath = targetIndexPath
                    cell.priceLabel.text = ""
                    
                    UserCustomization.buyedBallSkinIndexes += [targetIndexPath.item]
                    UserCustomization.ballSkinIndex = self.selectedCellIndexPath.item
                    GameCurrency.userMoney -= UInt(cell.price)
                    self.userMoneyLabel.text = "\(GameCurrency.userMoney)"
                    HapticManager.notificationVibrate(for: .success)
                } else if GameCurrency.userMoney < cell.price {
                    HapticManager.notificationVibrate(for: .error)
                }
                cell.resizeToIdentity()
                
            }
        
//        case .changed:
            
        case .ended:
            if targetIndexPath == self.selectedCellIndexPath {
                let cell = self.collectionView.cellForItem(at: targetIndexPath) as? ShopCollectionViewCell
                cell?.resizeToIdentity()
            }

            print("ended for - \(targetIndexPath.item)")
        case .cancelled:
            
            let cell = self.collectionView.cellForItem(at: targetIndexPath) as? ShopCollectionViewCell
            cell?.resizeToIdentity()
            print("cancelled for - \(targetIndexPath.item)")
        default:
            print("default")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userMoneyLabel.text = "\(GameCurrency.userMoney)"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        
    }
    // содержит ли массив с индексами купленных элементов определенный индекс
    private func doesBuyedItemsContains(item: IndexPath) -> Bool {
        var doesContain = false
        for index in UserCustomization.buyedBallSkinIndexes {
            if index == item.item {
                doesContain = true
            }
        }
        
        return doesContain
    }
}

// сколько чего и как создавать
extension ShopBallTexturesViewController: UICollectionViewDataSource {
    // сколько ячеек создавать
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ballCellData.count
    }
    // количество элементов в section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // какие ячейки создавать
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! ShopCollectionViewCell
        
        cell.setup(with: self.ballCellData[indexPath.item])
        if self.doesBuyedItemsContains(item: indexPath) {
            print("contains - \(indexPath.item)")
            cell.priceLabel.text = ""
            cell.backgroundColor = self.buyedColor
        }
        if self.selectedCellIndexPath == indexPath {
            cell.select()
        }
        let cornerRadius = 30.0
        cell.layer.cornerRadius = cornerRadius
        
        return cell
        
    }
}
// как располагать ячейки в collectionView
extension ShopBallTexturesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.width/2.7,
                          height: self.view.frame.width/2.7 * 1.3)
        return size
    }
}
// обработка нажатий
extension ShopBallTexturesViewController: UICollectionViewDelegate {
    // активируется, когда мы выбираем какой-то уже купленный скин
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? ShopCollectionViewCell {
            if self.doesBuyedItemsContains(item: indexPath) {
                if self.selectedCellIndexPath != indexPath {
                    self.selectedCellIndexPath = indexPath
                    cell.wasSelected()
                }
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? ShopCollectionViewCell {
            if !self.doesBuyedItemsContains(item: indexPath) {
                cell.touchDown()
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? ShopCollectionViewCell {
            if self.selectedCellIndexPath != indexPath {
                let isBuyed = self.doesBuyedItemsContains(item: indexPath)
                cell.wasUnselected(isBuyed: isBuyed)
                cell.resizeToIdentity()
            }
            
        }
    }
    
}
