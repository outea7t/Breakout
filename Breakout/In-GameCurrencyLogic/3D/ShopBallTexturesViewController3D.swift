//
//  ShopBallTexturesViewController3D.swift
//  Breakout
//
//  Created by Out East on 26.04.2023.
//

import Foundation
import UIKit
import SceneKit

class ShopBallTexturesViewController3D: UIViewController, Textures3DShopController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerTopView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userMoneyLabel: UILabel!
    
    private var ballCellData = [Shop3DCellData]()
    private let cellIdentifier = "Shop3DCollectionViewCell"
    // изменить
    var selectedCellIndexPath = IndexPath() {
        willSet {
            if newValue != selectedCellIndexPath {
                let unselectedCell = self.collectionView.cellForItem(at: selectedCellIndexPath) as? Shop3DCollectionViewCell
                unselectedCell?.wasUnselected(isBuyed: true)
                UserCustomization._3DballSkinIndex = newValue.item
            }
        }
    }
    // изменить
    var type = TypeOfShopController.ball
    // изменить
    private var cellMenuCellData: Shop3DCellData?
    private let unselectedColor = #colorLiteral(red: 0.05882352941, green: 0.01568627451, blue: 0.1176470588, alpha: 1)
    private let buyedColor = #colorLiteral(red: 0.3411764706, green: 0.1490196078, blue: 0.5843137255, alpha: 0.8)
    private let selectedColor = #colorLiteral(red: 0.2941176471, green: 0.09019607843, blue: 0.8823529412, alpha: 0.8)
    
    var selectedCellInfo: CellInfo3D?
    var selectedCell: Shop3DCollectionViewCell?
    var actualPositionOfSelectedCell = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // заполняем массив с текстурами
        // настраиваем информацию о ячейках
        let model1 = SCNScene(named: "Ball-1")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model2 = SCNScene(named: "Ball-2")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model3 = SCNScene(named: "Ball-3")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model4 = SCNScene(named: "Ball-4")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model5 = SCNScene(named: "Ball-5")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model6 = SCNScene(named: "Ball-6")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model7 = SCNScene(named: "Ball-7")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model8 = SCNScene(named: "Ball-8")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model9 = SCNScene(named: "Ball-9")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model10 = SCNScene(named: "Ball-10")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model11 = SCNScene(named: "Ball-11")!.rootNode.childNode(withName: "Ball", recursively: true)!
        let model12 = SCNScene(named: "Ball-12")!.rootNode.childNode(withName: "Ball", recursively: true)!
        
        let color = self.unselectedColor
        self.ballCellData = [
            Shop3DCellData(model: model1, backgroundColor: color, price: 10, id: 0, textureType: .ball),
            Shop3DCellData(model: model2, backgroundColor: color, price: 20, id: 1, textureType: .ball),
            Shop3DCellData(model: model3, backgroundColor: color, price: 30, id: 2, textureType: .ball),
            Shop3DCellData(model: model4, backgroundColor: color, price: 40, id: 3, textureType: .ball),
            Shop3DCellData(model: model5, backgroundColor: color, price: 50, id: 4, textureType: .ball),
            Shop3DCellData(model: model6, backgroundColor: color, price: 60, id: 5, textureType: .ball),
            Shop3DCellData(model: model7, backgroundColor: color, price: 70, id: 6, textureType: .ball),
            Shop3DCellData(model: model8, backgroundColor: color, price: 80, id: 7, textureType: .ball),
            Shop3DCellData(model: model9, backgroundColor: color, price: 90, id: 8, textureType: .ball),
            Shop3DCellData(model: model10, backgroundColor: color, price: 100, id: 9, textureType: .ball),
            Shop3DCellData(model: model11, backgroundColor: color, price: 110, id: 10, textureType: .ball),
            Shop3DCellData(model: model12, backgroundColor: color, price: 120, id: 11, textureType: .ball),
        ]
        
        // добавляем GR для распознавания жеста покупки ячейки
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        longPressGesture.minimumPressDuration = 0.4
        longPressGesture.numberOfTouchesRequired = 1
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        // настраиваем кнопку "назад"
        self.backButton.layer.shadowOpacity = 1.0
        self.backButton.layer.shadowColor = #colorLiteral(red: 0, green: 0.2737697661, blue: 0.1170392856, alpha: 1)
        self.backButton.layer.shadowOffset = CGSize(width: self.backButton.frame.width/25,
                                                    height: self.backButton.frame.height/15)
        self.backButton.layer.shadowRadius = 0
        
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
        
        if !UserCustomization._3DbuyedBallSkinIndexes.isEmpty {
            self.selectedCellIndexPath = IndexPath(item: UserCustomization._3DballSkinIndex, section: 0)
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
            if let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop3DCollectionViewCell {
                if !self.doesBuyedItemsContains(item: targetIndexPath) &&
                    GameCurrency.userMoney >= cell.price {
                    self.selectedCellIndexPath = targetIndexPath
                    cell.priceLabel.text = ""
                    
                    UserCustomization._3DbuyedBallSkinIndexes += [targetIndexPath.item]
                    UserCustomization._3DballSkinIndex = self.selectedCellIndexPath.item
                    GameCurrency.userMoney -= cell.price
                    self.userMoneyLabel.text = GameCurrency.updateUserMoneyLabel()
                    HapticManager.notificationVibrate(for: .success)
                } else if GameCurrency.userMoney < cell.price {
                    HapticManager.notificationVibrate(for: .error)
                }
                cell.resizeToIdentity()
            }
        case .ended:
            if targetIndexPath == self.selectedCellIndexPath {
                let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop3DCollectionViewCell
                cell?.resizeToIdentity()
            }
        case .cancelled:
            let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop3DCollectionViewCell
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
    // содержит ли массив с индексами купленных элементов определенный индекс
    private func doesBuyedItemsContains(item: IndexPath) -> Bool {
        var doesContain = false
        for index in UserCustomization._3DbuyedBallSkinIndexes {
            if index == item.item {
                doesContain = true
            }
        }
        return doesContain
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}

// сколько чего и как создавать
extension ShopBallTexturesViewController3D: UICollectionViewDataSource {
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
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! Shop3DCollectionViewCell
        
        cell.setup(with: self.ballCellData[indexPath.item])
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
}
// как располагать ячейки в collection view
extension ShopBallTexturesViewController3D: UICollectionViewDelegateFlowLayout {
    // по две в ряду
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.width/2.7,
                          height: self.view.frame.width/2.7 * 1.3)
        return size
    }
}
// взаимодействия с ячейками
extension ShopBallTexturesViewController3D: UICollectionViewDelegate {
    // активируется, когда мы выбираем какой-то уже купленный скин
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? Shop3DCollectionViewCell else {
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
                print(actualPosition, cell.frame.origin)
                self.actualPositionOfSelectedCell = actualPosition
                self.selectedCell?.layer.zPosition = 100
                if let borderColor = cell.layer.borderColor, let backgroundColor = cell.backgroundColor {
                    self.selectedCellInfo = CellInfo3D(frame: cell.frame,
                                                     borderWidth: cell.layer.borderWidth,
                                                     borderColor: borderColor,
                                                     cornerRadius: cell.layer.cornerRadius,
                                                     backgroundColor: backgroundColor)
                }
            }
            self.performSegue(withIdentifier: "FromBall3DToCellMenu3D", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cellMenu = segue.destination as? CellMenuViewController3D else {
            return
        }
        guard let cellMenuCellData = self.cellMenuCellData else {
            return
        }
        cellMenu.model = cellMenuCellData.model.clone()
        cellMenu.price = (cellMenuCellData.price)
        cellMenu.cellID = cellMenuCellData.id
        cellMenu.typeOfCurrentShopController = self.type
//        print(cellMenuCellData.price, cellMenuCellData.id)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? Shop3DCollectionViewCell {
            if !self.doesBuyedItemsContains(item: indexPath) {
                cell.touchDown()
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? Shop3DCollectionViewCell {
            if self.selectedCellIndexPath != indexPath {
                let isBuyed = self.doesBuyedItemsContains(item: indexPath)
                cell.wasUnselected(isBuyed: isBuyed)
                cell.resizeToIdentity()
            }
            
        }
    }
}
