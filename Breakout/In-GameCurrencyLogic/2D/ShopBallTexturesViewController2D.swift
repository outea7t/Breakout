//
//  ShopBallTexturesViewController.swift
//  Breakout
//
//  Created by Out East on 09.01.2023.
//

import UIKit

class ShopBallTexturesViewController: UIViewController, TexturesShopController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerTopView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userMoneyLabel: UILabel!
    @IBOutlet weak var BallIcon: UITabBarItem!
    
    var ballCellData = [Shop2DCellData]()
    private let cellIdentifier = "Shop2DCollectionViewCell"
    var selectedCellIndexPath = IndexPath() {
        willSet {
            if newValue != selectedCellIndexPath {
                let unselectedCell = self.collectionView.cellForItem(at: selectedCellIndexPath) as? Shop2DCollectionViewCell
                unselectedCell?.wasUnselected(isBuyed: true)
                UserCustomization._2DballSkinIndex = newValue.item
            }
        }
    }
    var type = TypeOfShopController.ball
    private var cellMenuCellData: Shop2DCellData?
    
    private let unselectedColor = #colorLiteral(red: 0.05882352941, green: 0.01568627451, blue: 0.1176470588, alpha: 1)
    private let buyedColor = #colorLiteral(red: 0.3411764706, green: 0.1490196078, blue: 0.5843137255, alpha: 0.8)
    private let selectedColor = #colorLiteral(red: 0.2941176471, green: 0.09019607843, blue: 0.8823529412, alpha: 0.8)
    
    
    var selectedCellInfo: CellInfo?
    var selectedCell: ShopCollectionViewCell?
    var actualPositionOfSelectedCell = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let ballUnselectedImage = UIImage(named: "BallUnselected.png"), let ballSelectedImage = UIImage(named: "BallSelected.png") {
            self.BallIcon.image = ballUnselectedImage
            self.BallIcon.selectedImage = ballSelectedImage
            self.BallIcon.standardAppearance?.selectionIndicatorImage = ballSelectedImage
            self.BallIcon.scrollEdgeAppearance?.selectionIndicatorImage = ballSelectedImage
        }
        
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
        layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 10, right: 30)
        
        
        self.collectionView.collectionViewLayout = layout
        
        // force-unwrapping, потому что я точно знаю, что эти картинки существуют в assets
        // настраиваем информацию о ячейках
//        let image1 = UIImage(named: "Ball-1")!
//        let image2 = UIImage(named: "Ball-2")!
//        let image3 = UIImage(named: "Ball-3")!
//        let image4 = UIImage(named: "Ball-4")!
//        let image5 = UIImage(named: "Ball-5")!
//        let image6 = UIImage(named: "Ball-6")!
//        let image7 = UIImage(named: "Ball-7")!
//        let image8 = UIImage(named: "Ball-8")!
//        let image9 = UIImage(named: "Ball-9")!
//        let image10 = UIImage(named: "Ball-10")!
//        let image11 = UIImage(named: "Ball-11")!
//        let image12 = UIImage(named: "Ball-12")!
        
        let color = self.unselectedColor
        for i in 1...UserCustomization._2DmaxBallSkinIndex {
            let image = UIImage(named: "Ball-\(i)")!
            let tempData = Shop2DCellData(image: image, price: 10, color: color, id: i-1, type: .ball)
            self.ballCellData.append(tempData)
        }
        
//        self.ballCellData = [
//            Shop2DCellData(image: image1, price: 10, color: color, id: 0, type: .ball),
//            Shop2DCellData(image: image2, price: 20, color: color, id: 1, type: .ball),
//            Shop2DCellData(image: image3, price: 30, color: color, id: 2, type: .ball),
//            Shop2DCellData(image: image4, price: 40, color: color, id: 3, type: .ball),
//            Shop2DCellData(image: image5, price: 50, color: color, id: 4, type: .ball),
//            Shop2DCellData(image: image6, price: 60, color: color, id: 5, type: .ball),
//            Shop2DCellData(image: image7, price: 70, color: color, id: 6, type: .ball),
//            Shop2DCellData(image: image8, price: 80, color: color, id: 7, type: .ball),
//            Shop2DCellData(image: image9, price: 90, color: color, id: 8, type: .ball),
//            Shop2DCellData(image: image10, price: 100, color: color, id: 9, type: .ball),
//            Shop2DCellData(image: image11, price: 110, color: color, id: 10, type: .ball),
//            Shop2DCellData(image: image12, price: 120, color: color, id: 11, type: .ball),
//        ]
        
//        UserCustomization._2DmaxBallSkinIndex = ballCellData.count

        self.collectionView.isPrefetchingEnabled = false
        // добавляем GR для распознавания жеста покупки ячейки
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        longPressGesture.minimumPressDuration = 0.4
        longPressGesture.numberOfTouchesRequired = 1
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        // настраиваем кнопку назад
        self.backButton.layer.shadowOpacity = 1.0
        self.backButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.2737697661, blue: 0.1170392856, alpha: 1)
        self.backButton.layer.shadowOffset = CGSize(width: self.backButton.frame.width/25,
                                                    height: self.backButton.frame.height/15)
        self.backButton.layer.shadowRadius = 0
        
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
        
        if !UserCustomization._2DbuyedBallSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization._2DballSkinIndex, section: 0)
        }
        
        
    }
    func updateInfo() {
        self.userMoneyLabel.text = (GameCurrency.updateUserMoneyLabel())
        self.collectionView.reloadData()
    }
    @objc func longPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: self.collectionView)
        guard let targetIndexPath = self.collectionView.indexPathForItem(at: gestureLocation) else {
            return
        }
        switch gesture.state {
        case .began:
            // находим нажатую ячейку
            if let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop2DCollectionViewCell {
                
                if !self.doesBuyedItemsContains(item: targetIndexPath) &&
                    GameCurrency.userMoney >= cell.price {
                    self.selectedCellIndexPath = targetIndexPath
                    cell.priceLabel.text = ""
                    
                    UserCustomization._2DbuyedBallSkinIndexes += [targetIndexPath.item]
                    UserCustomization._2DballSkinIndex = self.selectedCellIndexPath.item
                    GameCurrency.userMoney -= cell.price
                    self.userMoneyLabel.text = GameCurrency.updateUserMoneyLabel()
                    HapticManager.notificationVibrate(for: .success)
                } else if GameCurrency.userMoney < cell.price {
                    HapticManager.notificationVibrate(for: .error)
                }
                cell.resizeToIdentity()
            }
//        case .changed:
        case .ended:
            if targetIndexPath == self.selectedCellIndexPath {
                let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop2DCollectionViewCell
                cell?.resizeToIdentity()
            }
        case .cancelled:
            
            let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop2DCollectionViewCell
            cell?.resizeToIdentity()
        default:
            break
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userMoneyLabel.text = GameCurrency.updateUserMoneyLabel()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    // содержит ли массив с индексами купленных элементов определенный индекс
    private func doesBuyedItemsContains(item: IndexPath) -> Bool {
        var doesContain = false
        for index in UserCustomization._2DbuyedBallSkinIndexes {
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
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! Shop2DCollectionViewCell
        
        
        cell.setup(with: self.ballCellData[indexPath.row])
        cell.layer.borderWidth = 0
            
        if self.doesBuyedItemsContains(item: indexPath) {
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? Shop2DCollectionViewCell else {
            return
        }
        if self.doesBuyedItemsContains(item: indexPath) && self.selectedCellIndexPath != indexPath {
            self.selectedCellIndexPath = indexPath
            cell.wasSelected()
        }
        
        // В этом месте стоит вызывать функцию с переходом в расширенное меню со скином
        // Так как это место активируется только тогда, когда мы не затригерели longPressGestureRecognizer
        // Но когда нажали на ячейку
        if !self.doesBuyedItemsContains(item: indexPath) {
            if let cellData = cell.data {
                self.cellMenuCellData = cellData
                self.selectedCell = cell
                
                var actualPosition = cell.convert(cell.bounds, to: self.collectionView.superview).origin
                actualPosition = CGPoint(x: cell.frame.origin.x, y: actualPosition.y)
                // важно
                // вследствие того, что высота collection view гораздо больше высота superview мы должны вычислять позицию ячейки в этом superview для более логичной и правильной анимации
                self.actualPositionOfSelectedCell = actualPosition
                self.selectedCell?.layer.zPosition = 100
                if let borderColor = cell.layer.borderColor, let backgroundColor = cell.backgroundColor {
                    self.selectedCellInfo = CellInfo(frame: cell.frame,
                                                     borderWidth: cell.layer.borderWidth,
                                                     borderColor: borderColor,
                                                     cornerRadius: cell.layer.cornerRadius,
                                                     backgroundColor: backgroundColor,
                                                     skinViewFrame: cell.imageView.frame)
                }
            }
            self.performSegue(withIdentifier: "FromBallTexturesToCellMenu", sender: self)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cellMenu = segue.destination as? CellMenuViewController else {
            return
        }
        guard let cellMenuCellData = self.cellMenuCellData else {
            return
        }
        // для того, чтобы можно было просмотреть расширенную информацию о купленном скине
        guard let selectedCell = self.selectedCell else {
            return
        }
        if UserCustomization._2DbuyedBallSkinIndexes.contains(selectedCell.id) {
            cellMenu.shouldShowBuyButton = false
        }
        cellMenu.image = cellMenuCellData.image
        cellMenu.price = (cellMenuCellData.price)
        cellMenu.cellID = cellMenuCellData.id
        cellMenu.typeOfCurrentShopController = self.type
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? Shop2DCollectionViewCell {
            if !self.doesBuyedItemsContains(item: indexPath) {
                cell.touchDown()
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? Shop2DCollectionViewCell {
            if self.selectedCellIndexPath != indexPath {
                let isBuyed = self.doesBuyedItemsContains(item: indexPath)
                cell.wasUnselected(isBuyed: isBuyed)
                cell.resizeToIdentity()
            }
            
        }
    }
    
}

