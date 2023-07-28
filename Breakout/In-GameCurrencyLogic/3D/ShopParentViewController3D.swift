//
//  ShopParentViewController3D.swift
//  Breakout
//
//  Created by Out East on 24.07.2023.
//

import Foundation
import UIKit

class ShopParentViewController3D: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerTopView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userMoneyLabel: UILabel!
    
    internal var cellData = [Shop3DCellData]()
    internal let cellIdentifier = "Shop3DCollectionViewCell"
    // изменить
    var selectedCellIndexPath = IndexPath() {
        willSet {
            guard newValue != selectedCellIndexPath else {
                return
            }
            guard let type = (self.collectionView.delegate as? TexturesShopController)?.type else {
                return
            }
            let unselectedCell = self.collectionView.cellForItem(at: selectedCellIndexPath) as? Shop3DCollectionViewCell
            unselectedCell?.wasUnselected(isBuyed: true)
            switch type {
                case .ball:
                    UserCustomization._3DballSkinIndex = newValue.item
                case .paddle:
                    UserCustomization._3DpaddleSkinIndex = newValue.item
                case .particles:
                    UserCustomization._3DparticleSkinIndex = newValue.item
                default:
                    break
            }
            
        }
    }
    // изменить
    internal var cellMenuCellData: Shop3DCellData?
    internal let unselectedColor = #colorLiteral(red: 0.05882352941, green: 0.01568627451, blue: 0.1176470588, alpha: 1)
    internal let buyedColor = #colorLiteral(red: 0.3411764706, green: 0.1490196078, blue: 0.5843137255, alpha: 0.8)
    internal let selectedColor = #colorLiteral(red: 0.2941176471, green: 0.09019607843, blue: 0.8823529412, alpha: 0.8)
    
    var selectedCellInfo: CellInfo?
    var selectedCell: ShopCollectionViewCell?
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
        guard let type = (self.collectionView.delegate as? TexturesShopController)?.type else {
            return
        }
        
        switch gesture.state {
        case .began:
            if let cell = self.collectionView.cellForItem(at: targetIndexPath) as? Shop3DCollectionViewCell {
                if !self.doesBuyedItemsContains(item: targetIndexPath) &&
                    GameCurrency.userMoney >= cell.price {
                    self.selectedCellIndexPath = targetIndexPath
                    cell.priceLabel.text = ""
                    
                    switch type {
                    case .ball:
                        UserCustomization._3DbuyedBallSkinIndexes += [targetIndexPath.item]
                        UserCustomization._3DballSkinIndex = self.selectedCellIndexPath.item
                    case .paddle:
                        UserCustomization._3DbuyedPaddleSkinIndexes += [targetIndexPath.item]
                        UserCustomization._3DpaddleSkinIndex = self.selectedCellIndexPath.item
                    case .particles:
                        UserCustomization._3DbuyedParticlesSkinIndexes += [targetIndexPath.item]
                        UserCustomization._3DparticleSkinIndex = self.selectedCellIndexPath.item
                    default:
                        break
                    }
                    
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
    
    // содержит ли массив с индексами купленных элементов определенный индекс
    internal func doesBuyedItemsContains(item: IndexPath) -> Bool {
        guard let type = (self.collectionView.delegate as? TexturesShopController)?.type else {
            return false
        }
        var currentArrayOfSkins = [Int]()
        switch type {
        case .ball:
            currentArrayOfSkins = UserCustomization._3DbuyedBallSkinIndexes
        case .paddle:
            currentArrayOfSkins = UserCustomization._3DbuyedPaddleSkinIndexes
        case .particles:
            currentArrayOfSkins = UserCustomization._3DbuyedParticlesSkinIndexes
        default:
            break
        }
        var doesContain = false
        for index in currentArrayOfSkins {
            if index == item.item {
                doesContain = true
            }
        }
        return doesContain
    }
}


// сколько чего и как создавать
extension ShopParentViewController3D: UICollectionViewDataSource {
    // сколько ячеек создавать
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellData.count
    }
    // количество элементов в section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // какие ячейки создавать
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! Shop3DCollectionViewCell
        
        cell.setup(with: self.cellData[indexPath.item])
        cell.layer.borderWidth = 0
        
        if self.doesBuyedItemsContains(item: indexPath) {
            cell.priceLabel.text = ""
            cell.moveModelBackWhenBuyed()
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
extension ShopParentViewController3D: UICollectionViewDelegateFlowLayout {
    // по две в ряду
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.width/2.7,
                          height: self.view.frame.width/2.7 * 1.3)
        return size
    }
}
// взаимодействия с ячейками
extension ShopParentViewController3D: UICollectionViewDelegate {
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
                print(cell.scnView.frame)
                if let borderColor = cell.layer.borderColor, let backgroundColor = cell.backgroundColor {
                    self.selectedCellInfo = CellInfo(frame: cell.frame,
                                                     borderWidth: cell.layer.borderWidth,
                                                     borderColor: borderColor,
                                                     cornerRadius: cell.layer.cornerRadius,
                                                     backgroundColor: backgroundColor,
                                                     skinViewFrame: cell.scnView.frame
                    )
                }
            }
            
            guard let type = (self.collectionView.delegate as? TexturesShopController)?.type else {
                return
            }
            
            switch type {
            case .ball:
                self.performSegue(withIdentifier: "FromBall3DToCellMenu3D", sender: self)
            case .paddle:
                self.performSegue(withIdentifier: "FromPaddle3DToCellMenu3D", sender: self)
            case .particles:
                self.performSegue(withIdentifier: "FromParticles3DToCellMenu3D", sender: self)
            default:
                break
            }
            
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
        guard let type = (self.collectionView.delegate as? TexturesShopController)?.type else {
            return
        }
        cellMenu.typeOfCurrentShopController = type
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
