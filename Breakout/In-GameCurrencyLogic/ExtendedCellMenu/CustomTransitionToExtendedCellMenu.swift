//
//  CustomTransitionToExtendedCellMenu.swift
//  Breakout
//
//  Created by Out East on 18.04.2023.
//

import UIKit

class CustomTransitionToExtendedCellMenu: NSObject {
    private let animationDuration: TimeInterval
    private let animationType: AnimationType
    enum AnimationType {
        case present
        case dismiss
    }
    init(animationDuration: TimeInterval, animationType: AnimationType) {
        self.animationDuration = animationDuration
        self.animationType = animationType
    }

}

extension CustomTransitionToExtendedCellMenu: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animationDuration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
            print("FUCK1")
            transitionContext.completeTransition(false)
            return
        }
        switch self.animationType {
        case .present:
            transitionContext.containerView.addSubview(fromViewController.view)
            transitionContext.containerView.addSubview(toViewController.view)
            self.presentAnimation(with: transitionContext)
        case .dismiss:
//            transitionContext.containerView.addSubview(toViewController.view)
            self.dismissAnimation(with: transitionContext)
        }
    }
    func dismissAnimation(with transitionContext: UIViewControllerContextTransitioning) {
        guard let shopViewController = transitionContext.viewController(forKey: .to) as? ShopViewController else{
            print(type(of: transitionContext.viewController(forKey: .from)))
            print("BALLTEXTUREs")
            transitionContext.completeTransition(false)
            return
        }
        guard let extendedCellMenuViewController = transitionContext.viewController(forKey: .from) as? CellMenuViewController else {
            print("CELLMENU")
            transitionContext.completeTransition(false)
            return
        }
        var _controller: ShopBallTexturesViewController?
        if let viewControllers = shopViewController.viewControllers {
            for viewController in viewControllers {
                if let controller = viewController as? ShopBallTexturesViewController {
                    _controller = controller
                }
            }
        }
        guard let firstViewController = _controller else {
            transitionContext.completeTransition(false)
            return
        }
        let blurView = extendedCellMenuViewController.blurView
        
        guard let selectedCellInfo = firstViewController.selectedCellInfo else {
            return
        }
        
        let toFrame = selectedCellInfo.frame
        let toBorderColor = selectedCellInfo.borderColor
        let toBorderWidth = selectedCellInfo.borderWidth
        let toCornerRadius = selectedCellInfo.cornerRadius
        let toBackgroundColor = selectedCellInfo.backgroundColor
         
        let toImageViewFrame = selectedCellInfo.imageFrame
         
        blurView?.alpha = 1.0
        UIView.animate(withDuration: 1.5,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .curveLinear,
                       animations: {
            blurView?.alpha = 0.0
        })
         
         
        extendedCellMenuViewController.buyButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            extendedCellMenuViewController.buyButton.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
        })
         
        extendedCellMenuViewController.priceLabel.alpha = 1.0
        extendedCellMenuViewController.effectsLabel.alpha = 1.0
        extendedCellMenuViewController.effectsInformationLabel.alpha = 1.0
        extendedCellMenuViewController.moneyLabel.alpha = 1.0
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: {
            extendedCellMenuViewController.priceLabel.alpha = 0.0
            extendedCellMenuViewController.moneyLabel.alpha = 0.0
            extendedCellMenuViewController.effectsLabel.alpha = 0.0
            extendedCellMenuViewController.effectsInformationLabel.alpha = 0.0
        })
         
        let selectedCell = firstViewController.selectedCell
        if let cellView = extendedCellMenuViewController.cellInformationView {
            selectedCell?.frame.size = cellView.frame.size
            selectedCell?.frame.origin = CGPoint(x: cellView.frame.origin.x,
                                                y: cellView.frame.origin.y-128)
            selectedCell?.layer.cornerRadius = cellView.layer.cornerRadius
            selectedCell?.layer.borderColor = cellView.layer.borderColor
            selectedCell?.layer.borderWidth = cellView.layer.borderWidth
            selectedCell?.backgroundColor = cellView.backgroundColor
            selectedCell?.alpha = 1.0
            cellView.alpha = 0.0
        }
        let selectedCellImageView = firstViewController.selectedCell?.imageView
        if let extendedImageView = extendedCellMenuViewController.skinImageView {
            selectedCellImageView?.image = extendedImageView.image
            selectedCellImageView?.frame = extendedImageView.frame
            selectedCellImageView?.alpha = 1.0
            extendedImageView.alpha = 0.0
        }
        UIView.animate(withDuration: 1.1,
                       delay: 0.4,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.6,
                       options: .curveEaseOut,
                       animations: {
            selectedCell?.frame = toFrame
            selectedCell?.layer.borderColor = toBorderColor
            selectedCell?.layer.borderWidth = toBorderWidth
            selectedCell?.layer.cornerRadius = toCornerRadius
            selectedCell?.backgroundColor = toBackgroundColor
            selectedCellImageView?.frame = toImageViewFrame
        }) { _ in
            transitionContext.completeTransition(true)
            firstViewController.view.layoutIfNeeded()
//            extendedCellViewController.view.isHidden = true
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let keyWindow = windowScene.windows.first(where: {$0.isKeyWindow}) {
                    keyWindow.addSubview(firstViewController.view)
                }
            }
        }
    }
    
    func presentAnimation(with transitionContext: UIViewControllerContextTransitioning) {
        guard let shopViewController = transitionContext.viewController(forKey: .from) as? ShopViewController else{
            print(type(of: transitionContext.viewController(forKey: .from)))
            print("BALLTEXTUREs")
            transitionContext.completeTransition(false)
            return
        }
        guard let extendedCellMenuViewController = transitionContext.viewController(forKey: .to) as? CellMenuViewController else {
            print("CELLMENU")
            transitionContext.completeTransition(false)
            return
        }
        var _controller: ShopBallTexturesViewController?
        if let viewControllers = shopViewController.viewControllers {
            for viewController in viewControllers {
                if let controller = viewController as? ShopBallTexturesViewController {
                    _controller = controller
                }
            }
        }
        guard let firstViewController = _controller else {
            transitionContext.completeTransition(false)
            return
        }
        let blurView = extendedCellMenuViewController.blurView
        
        let toFrame = extendedCellMenuViewController.cellInformationView.frame
        let toBorderColor = extendedCellMenuViewController.cellInformationView.layer.borderColor
        let toBorderWidth = extendedCellMenuViewController.cellInformationView.layer.borderWidth
        let toCornerRadius = extendedCellMenuViewController.cellInformationView.layer.cornerRadius
        let toBackgroundColor = extendedCellMenuViewController.cellInformationView.backgroundColor
        
        let toImageViewFrame = extendedCellMenuViewController.skinImageView.frame
        
        blurView?.alpha = 0.0
        UIView.animate(withDuration: 1.5,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .curveLinear,
                       animations: {
            blurView?.alpha = 1.0
        })
        
        let extendedCellView = extendedCellMenuViewController.cellInformationView
        if let cellView = firstViewController.selectedCell {
            extendedCellView?.frame.size = cellView.frame.size
            extendedCellView?.frame.origin = CGPoint(x: cellView.frame.origin.x,
                                                     y: cellView.frame.origin.y+128)
            extendedCellView?.layer.cornerRadius = cellView.layer.cornerRadius
            extendedCellView?.layer.borderColor = cellView.layer.borderColor
            extendedCellView?.layer.borderWidth = cellView.layer.borderWidth
            extendedCellView?.backgroundColor = cellView.backgroundColor
            extendedCellView?.alpha = 1.0
            cellView.alpha = 0.0
        }
        let extendedCellImageView = extendedCellMenuViewController.skinImageView
        if let firstImageView = firstViewController.selectedCell?.imageView {
            extendedCellImageView?.image = firstImageView.image
            extendedCellImageView?.frame = firstImageView.frame
            extendedCellImageView?.alpha = 1.0
            firstImageView.alpha = 0.0
        }
        
        UIView.animate(withDuration: 1.1,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.6,
                       options: .curveEaseOut,
                       animations: {
            extendedCellView?.frame = toFrame
            extendedCellView?.layer.borderColor = toBorderColor
            extendedCellView?.layer.borderWidth = toBorderWidth
            extendedCellView?.layer.cornerRadius = toCornerRadius
            extendedCellView?.backgroundColor = toBackgroundColor
            extendedCellImageView?.frame = toImageViewFrame
        })
        
        
        extendedCellMenuViewController.buyButton.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
        UIView.animate(withDuration: 0.4,
                       delay: 1.1,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            extendedCellMenuViewController.buyButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        
        extendedCellMenuViewController.priceLabel.alpha = 0.0
        extendedCellMenuViewController.effectsLabel.alpha = 0.0
        extendedCellMenuViewController.effectsInformationLabel.alpha = 0.0
        extendedCellMenuViewController.moneyLabel.alpha = 0.0
        UIView.animate(withDuration: 0.3,
                       delay: 1.3,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: {
            extendedCellMenuViewController.priceLabel.alpha = 1.0
            extendedCellMenuViewController.moneyLabel.alpha = 1.0
            extendedCellMenuViewController.effectsLabel.alpha = 1.0
            extendedCellMenuViewController.effectsInformationLabel.alpha = 1.0
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}