////
////  ShopParentViewController2D.swift
////  Breakout
////
////  Created by Out East on 23.07.2023.
////
//
//import Foundation
//import UIKit
//
//class ShopParentViewController2D: UIViewController {
//    
//    var ballCellData = [Shop2DCellData]()
//    private let cellIdentifier = "Shop2DCollectionViewCell"
//    var selectedCellIndexPath = IndexPath() {
//        willSet {
//            if newValue != selectedCellIndexPath {
//                let unselectedCell = self.collectionView.cellForItem(at: selectedCellIndexPath) as? Shop2DCollectionViewCell
//                unselectedCell?.wasUnselected(isBuyed: true)
//                switch self.type {
//                case .ball:
//                    UserCustomization._2DballSkinIndex = newValue.item
//                case .paddle:
//                    UserCustomization._2DpaddleSkinIndex = newValue.item
//                case .particles:
//                    UserCustomization.
//                }
//                
//            }
//        }
//    }
//    var type = TypeOfShopController.ball
//    private var cellMenuCellData: Shop2DCellData?
//    
//    private let unselectedColor = #colorLiteral(red: 0.05882352941, green: 0.01568627451, blue: 0.1176470588, alpha: 1)
//    private let buyedColor = #colorLiteral(red: 0.3411764706, green: 0.1490196078, blue: 0.5843137255, alpha: 0.8)
//    private let selectedColor = #colorLiteral(red: 0.2941176471, green: 0.09019607843, blue: 0.8823529412, alpha: 0.8)
//    
//    
//    var selectedCellInfo: CellInfo?
//    var selectedCell: ShopCollectionViewCell?
//    var actualPositionOfSelectedCell = CGPoint()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if let ballUnselectedImage = UIImage(named: "BallUnselected.png"), let ballSelectedImage = UIImage(named: "BallSelected.png") {
//            self.BallIcon.image = ballUnselectedImage
//            self.BallIcon.selectedImage = ballSelectedImage
//            self.BallIcon.standardAppearance?.selectionIndicatorImage = ballSelectedImage
//            self.BallIcon.scrollEdgeAppearance?.selectionIndicatorImage = ballSelectedImage
//        }
//        
//        // находим класс, который будем использовать для ячеек
//        let cellClass = UINib(nibName: self.cellIdentifier, bundle: nil)
//        self.collectionView.register(cellClass, forCellWithReuseIdentifier: self.cellIdentifier)
//        self.collectionView.dataSource = self
//        self.collectionView.delegate = self
//        
//        // настраиваем расположение ячеек в collectionView
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 12
//        layout.minimumInteritemSpacing = 12
//        // отступы от конкретных граней
//        layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 10, right: 30)
//        
//        
//        self.collectionView.collectionViewLayout = layout
//        
//        // force-unwrapping, потому что я точно знаю, что эти картинки существуют в assets
//        // настраиваем информацию о ячейках
////        let image1 = UIImage(named: "Ball-1")!
////        let image2 = UIImage(named: "Ball-2")!
////        let image3 = UIImage(named: "Ball-3")!
////        let image4 = UIImage(named: "Ball-4")!
////        let image5 = UIImage(named: "Ball-5")!
////        let image6 = UIImage(named: "Ball-6")!
////        let image7 = UIImage(named: "Ball-7")!
////        let image8 = UIImage(named: "Ball-8")!
////        let image9 = UIImage(named: "Ball-9")!
////        let image10 = UIImage(named: "Ball-10")!
////        let image11 = UIImage(named: "Ball-11")!
////        let image12 = UIImage(named: "Ball-12")!
//        
//        let color = self.unselectedColor
//        for i in 1...UserCustomization._2DmaxBallSkinIndex {
//            let image = UIImage(named: "Ball-\(i)")!
//            let tempData = Shop2DCellData(image: image, price: 10, color: color, id: i-1, type: .ball)
//            self.ballCellData.append(tempData)
//        }
//        
////        self.ballCellData = [
////            Shop2DCellData(image: image1, price: 10, color: color, id: 0, type: .ball),
////            Shop2DCellData(image: image2, price: 20, color: color, id: 1, type: .ball),
////            Shop2DCellData(image: image3, price: 30, color: color, id: 2, type: .ball),
////            Shop2DCellData(image: image4, price: 40, color: color, id: 3, type: .ball),
////            Shop2DCellData(image: image5, price: 50, color: color, id: 4, type: .ball),
////            Shop2DCellData(image: image6, price: 60, color: color, id: 5, type: .ball),
////            Shop2DCellData(image: image7, price: 70, color: color, id: 6, type: .ball),
////            Shop2DCellData(image: image8, price: 80, color: color, id: 7, type: .ball),
////            Shop2DCellData(image: image9, price: 90, color: color, id: 8, type: .ball),
////            Shop2DCellData(image: image10, price: 100, color: color, id: 9, type: .ball),
////            Shop2DCellData(image: image11, price: 110, color: color, id: 10, type: .ball),
////            Shop2DCellData(image: image12, price: 120, color: color, id: 11, type: .ball),
////        ]
//        
////        UserCustomization._2DmaxBallSkinIndex = ballCellData.count
//
//        self.collectionView.isPrefetchingEnabled = false
//        // добавляем GR для распознавания жеста покупки ячейки
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
//        longPressGesture.minimumPressDuration = 0.4
//        longPressGesture.numberOfTouchesRequired = 1
//        self.collectionView.addGestureRecognizer(longPressGesture)
//        
//        // настраиваем кнопку назад
//        self.backButton.layer.shadowOpacity = 1.0
//        self.backButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.2737697661, blue: 0.1170392856, alpha: 1)
//        self.backButton.layer.shadowOffset = CGSize(width: self.backButton.frame.width/25,
//                                                    height: self.backButton.frame.height/15)
//        self.backButton.layer.shadowRadius = 0
//        
//        super.viewDidLoad()
//        // настраиваем верхнее меню
//        self.headerTopView.layer.cornerRadius = 20.0
//        self.headerTopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        // настраиваем тень
//        self.headerTopView.layer.shadowOpacity = 1.0
//        self.headerTopView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
//        self.headerTopView.layer.shadowOffset = CGSize(width: 0.0,
//                                                       height: 15.0)
//        self.headerTopView.layer.shadowRadius = 8
//        
//        // для того, чтобы была видна тень
//        self.view.sendSubviewToBack(self.collectionView)
//        
//        if !UserCustomization._2DbuyedBallSkinIndexes.isEmpty {
//            self.selectedCellIndexPath = IndexPath(item: UserCustomization._2DballSkinIndex, section: 0)
//        }
//        
//        
//    }
//    func updateInfo() {
//        self.userMoneyLabel.text = (GameCurrency.updateUserMoneyLabel())
//        self.collectionView.reloadData()
//    }
//    @objc func longPressGesture(_ gesture: UILongPressGestureRecognizer) {
//        let gestureLocation = gesture.location(in: self.collectionView)
//        guard let targetIndexPath = self.collectionView.indexPathForItem(at: gestureLocation) else {
//            return
//        }
//        switch gesture.state {
//        case .began:
//            // находим нажатую ячейку
//            if let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop2DCollectionViewCell {
//                
//                if !self.doesBuyedItemsContains(item: targetIndexPath) &&
//                    GameCurrency.userMoney >= cell.price {
//                    self.selectedCellIndexPath = targetIndexPath
//                    cell.priceLabel.text = ""
//                    
//                    UserCustomization._2DbuyedBallSkinIndexes += [targetIndexPath.item]
//                    UserCustomization._2DballSkinIndex = self.selectedCellIndexPath.item
//                    GameCurrency.userMoney -= cell.price
//                    self.userMoneyLabel.text = GameCurrency.updateUserMoneyLabel()
//                    HapticManager.notificationVibrate(for: .success)
//                } else if GameCurrency.userMoney < cell.price {
//                    HapticManager.notificationVibrate(for: .error)
//                }
//                cell.resizeToIdentity()
//            }
////        case .changed:
//        case .ended:
//            if targetIndexPath == self.selectedCellIndexPath {
//                let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop2DCollectionViewCell
//                cell?.resizeToIdentity()
//            }
//        case .cancelled:
//            
//            let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop2DCollectionViewCell
//            cell?.resizeToIdentity()
//        default:
//            break
//        }
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.userMoneyLabel.text = GameCurrency.updateUserMoneyLabel()
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//    }
//    @IBAction func backButtonPressed(_ sender: UIButton) {
//        DispatchQueue.main.async {
//            self.dismiss(animated: true)
//        }
//    }
//    // содержит ли массив с индексами купленных элементов определенный индекс
//    private func doesBuyedItemsContains(item: IndexPath) -> Bool {
//        var doesContain = false
//        for index in UserCustomization._2DbuyedBallSkinIndexes {
//            if index == item.item {
//                doesContain = true
//            }
//        }
//        return doesContain
//    }
//}
