//
//  CoachingViewController.swift
//  Breakout
//
//  Created by Out East on 07.08.2023.
//

import UIKit

class CoachingViewController2D: UIViewController {

    private var pageControl: UIPageControl = {
       let pageControl = UIPageControl()
        pageControl.backgroundColor = .clear
        return pageControl
    }()
    
    private var scrollView = UIScrollView()
    private var maxPages: Int = 3
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.scrollView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: self.view.bounds.width,
                                  height: self.view.bounds.height)
        self.scrollView.isPagingEnabled = true
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(self.maxPages),
                                        height: self.view.bounds.height)
        
        self.view.addSubview(scrollView)
        
        self.scrollView.showsHorizontalScrollIndicator = true
        self.view.addSubview(self.pageControl)
        
        self.scrollView.backgroundColor = #colorLiteral(red: 0.01813352294, green: 0.04795820266, blue: 0.1062471047, alpha: 1)
        
        self.pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0, green: 1, blue: 0.412966907, alpha: 1)
        self.pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.pageControl.numberOfPages = self.maxPages
        self.scrollView.delegate = self
        
        self.pageControl.addTarget(self,
                                   action: #selector(self.pageControlDidChange),
                                   for: .valueChanged)
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        self.scrollView.setContentOffset(CGPoint(x: CGFloat(current) * self.view.frame.size.width, y: 0), animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        self.pageControl.frame = CGRect(x: 10,
//                                        y: scrollView.frame.size.height-100,
//                                        width: scrollView.frame.size.width-20, height: 70/844 * self.view.frame.height)
        
        if self.scrollView.subviews.count == 2 {
            print("configured")
            self.configurePages()
        }
    }
    
    private func configurePages() {
        let colors = [
            #colorLiteral(red: 0.06077173352, green: 0, blue: 0.1810952425, alpha: 1),
            #colorLiteral(red: 0.06077173352, green: 0, blue: 0.1810952425, alpha: 1),
            #colorLiteral(red: 0.06077173352, green: 0, blue: 0.1810952425, alpha: 1)
        ]
        
        let images = [
            UIImage(named: "FirstImage.png"),
            UIImage(named: "FirstImage.png"),
            UIImage(named: "FirstImage.png")
        ]
        
        let texts = [
            "Choose well lit matte surfaces for better plane tracking",
            "Wait till the plain will be detected",
            "When the game frame will appear, move your phone to pick a better frame position, then tap on the screen to lock the position"
        ]
        var pages = [UIView]()
        for i in 0..<self.maxPages {
            let page = UIView(frame: CGRect(x: CGFloat(i) * self.view.frame.width,
                                            y: 0,
                                            width: self.view.frame.width,
                                            height: self.view.frame.height))
            page.backgroundColor = colors[i]
            
            
            let imageView = UIImageView(image: images[i])
            imageView.contentMode = .scaleToFill
            let imageViewSize = CGSize(width: self.view.frame.width/1.5,
                                       height: self.view.frame.height/1.85)
            let imageViewPosition = CGPoint(x: self.view.center.x,
                                            y: self.view.center.y - imageViewSize.height/4)
            imageView.frame = CGRect(origin: imageViewPosition, size: imageViewSize)
            imageView.center = imageViewPosition
            
            
            page.addSubview(imageView)
            pages.append(imageView)
            
            let textLabel = UILabel()
            textLabel.text = texts[i]
            page.addSubview(textLabel)
            
            textLabel.textColor = .white
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.textAlignment = .center
            
//            textLabel.lineBreakMode = .byWordWrapping
            textLabel.numberOfLines = -1
            textLabel.font = UIFont(name: "Impact", size: 60)
            textLabel.minimumScaleFactor = 0.05
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            var textConstraints = [NSLayoutConstraint]()
            
            textConstraints.append(textLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 25))
            textConstraints.append(textLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -25))
            textConstraints.append(textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50/844 * self.view.frame.height))
            textConstraints.append(textLabel.bottomAnchor.constraint(equalTo: page.bottomAnchor, constant: -50))
            
            NSLayoutConstraint.activate(textConstraints)
            
            
            self.scrollView.addSubview(page)
        }
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.pageControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        constraints.append(self.pageControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15))
        constraints.append(self.pageControl.topAnchor.constraint(equalTo: pages[0].bottomAnchor, constant: 10))
        constraints.append(self.pageControl.heightAnchor.constraint(equalToConstant: 50/844 * self.view.frame.height))
        
        NSLayoutConstraint.activate(constraints)
       
    }
}

extension CoachingViewController2D: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x / scrollView.frame.size.width)))
    }
}
