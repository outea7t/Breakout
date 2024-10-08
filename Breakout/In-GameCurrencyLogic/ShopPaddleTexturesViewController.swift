//
//  ShopPaddleTexturesViewController.swift
//  Breakout
//
//  Created by Out East on 22.02.2023.
//

import UIKit

class ShopPaddleTexturesViewController: UIViewController {
        
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerTopView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userMoneyLabel: UILabel!
    
    private var paddleCellData = [ShopCellData]()
    private let cellIdentifier = "ShopCollectionViewCell"
    private var selectedCellIndexPath = IndexPath() {
        willSet {
            if newValue != selectedCellIndexPath {
                let unselectedCell = self.collectionView.cellForItem(at: selectedCellIndexPath) as? ShopCollectionViewCell
                unselectedCell?.wasUnselected(isBuyed: true)
                UserCustomization.paddleSkinIndex = newValue.item
            }
        }
    }
    private let unselectedColor = #colorLiteral(red: 0.05882352941, green: 0.01568627451, blue: 0.1176470588, alpha: 1)
    private let buyedColor = #colorLiteral(red: 0.3411764706, green: 0.1490196078, blue: 0.5843137255, alpha: 0.8)
    private let selectedColor = #colorLiteral(red: 0.2941176471, green: 0.09019607843, blue: 0.8823529412, alpha: 0.8)
    
    override func viewDidLoad() {
        // находим класс ячеек и устанавливаем его в collectionView
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
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        
        
        self.collectionView.collectionViewLayout = layout
        
        // заполняем массив с текстурами
        // настраиваем информацию о ячейках
        let image1 = UIImage(named: "Particle-1")!
        let image2 = UIImage(named: "Particle-2")!
        let image3 = UIImage(named: "Particle-3")!
        let image4 = UIImage(named: "Particle-4")!
        let image5 = UIImage(named: "Particle-5")!
        let image6 = UIImage(named: "Particle-6")!
        let color = self.unselectedColor
        self.paddleCellData = [
            ShopCellData(image: image1, price: 10, color: color, id: 0),
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
        
        
        self.view.sendSubviewToBack(self.collectionView)
        
        if !UserCustomization.buyedPaddleSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization.paddleSkinIndex, section: 0)
        }
        // Do any additional setup after loading the view.
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
                    
                    UserCustomization.buyedPaddleSkinIndexes += [targetIndexPath.item]
                    UserCustomization.paddleSkinIndex = self.selectedCellIndexPath.item
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
        for index in UserCustomization.buyedPaddleSkinIndexes {
            if index == item.item {
                doesContain = true
            }
        }
        
        return doesContain
    }
}
// сколько чего и как создавать
extension ShopPaddleTexturesViewController: UICollectionViewDataSource {
    // сколько ячеек создавать
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.paddleCellData.count
    }
    // количество элементов в section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // какие ячейки создавать
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! ShopCollectionViewCell
        
        cell.setup(with: self.paddleCellData[indexPath.item])
        if self.doesBuyedItemsContains(item: indexPath) {
            cell.priceLabel.text = ""
            cell.backgroundColor = self.buyedColor
        }
        if self.selectedCellIndexPath == indexPath {
            cell.backgroundColor = self.selectedColor
            cell.wasSelected()
        }
        let cornerRadius = 30.0
        cell.layer.cornerRadius = cornerRadius
        
        return cell
        
    }
}
// как располагать ячейки в collection view
extension ShopPaddleTexturesViewController: UICollectionViewDelegateFlowLayout {
    // по две в ряду
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.width/2.2,
                          height: self.view.frame.width/2.2 * 1.5)
        return size
    }
}
// взаимодействия с ячейками
extension ShopPaddleTexturesViewController: UICollectionViewDelegate {
    // активируется, когда мы выбираем какой-то уже купленный скин
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? ShopCollectionViewCell {
            if self.doesBuyedItemsContains(item: indexPath) {
                if self.selectedCellIndexPath != indexPath {
                    self.selectedCellIndexPath = indexPath
                    UserCustomization.paddleSkinIndex = self.selectedCellIndexPath.item
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
