//
//  CrouselView.swift
//  AtlysTask
//
//  Created by Rahul on 29/11/24.
//

import UIKit

class CrouselView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var crouselContainer: UIView!
    
    // MARK: - Variables
    var views: [CrouselItemView] = []
    var currentIndex = 0
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    var sideMargin: CGFloat {
        let totalMargin = self.crouselContainer.frame.width - self.fullHeight + CGFloat(overlapMargion/3)
        let mar = totalMargin/2
        return mar
    }
    var zoomFactor: CGFloat {
        return 1.4
    }
    var fullHeight: CGFloat {
        return halfHeight * zoomFactor
    }
    var halfHeight: CGFloat {
        return self.crouselContainer.frame.height * 0.7
    }
    var overlapMargion: Int {
        return -40
    }
    
    // MARK: - Functions
    func additems(items: [UIImage?]) {
        views = []
        self.addPanGesture()
        self.setupPageIndicator(number: items.count)
        for item in items {
            //Creating and Adding imageContainer View to crousel
            guard let child = Bundle.main.loadNibNamed("CrouselItemView", owner: nil, options: nil)?.first as? CrouselItemView else { fatalError() }
            
            self.crouselContainer.addSubview(child)
            views.append(child)
            child.setData(item: item)
            
            //Adding Constraints to imageContainerView
            child.translatesAutoresizingMaskIntoConstraints = false
            if views.count == 1 {
                child.leadingConstraint = child.leadingAnchor.constraint(equalTo: self.crouselContainer.leadingAnchor, constant: sideMargin)
            } else {
                child.leadingConstraint = child.leadingAnchor.constraint(equalTo: self.views[views.count - 2].trailingAnchor, constant: -CGFloat(overlapMargion))
            }
            child.centerYAnchor.constraint(equalTo: self.crouselContainer.centerYAnchor).isActive = true
            child.heightAnchor.constraint(equalToConstant: self.halfHeight).isActive = true
            child.widthAnchor.constraint(equalToConstant: self.halfHeight).isActive = true
            child.leadingConstraint?.isActive = true
            child.originTransform = child.transform
        }
        self.currentIndex = items.count / 2
        //Setting Crousel To Middle Item
        self.scrollToIndex(index: currentIndex)
    }
    
    func setupPageIndicator(number: Int) {
        self.pageIndicator.numberOfPages = number
        self.pageIndicator.currentPage = currentIndex
        self.pageIndicator.isUserInteractionEnabled = false
        self.pageIndicator.pageIndicatorTintColor = .gray
        self.pageIndicator.currentPageIndicatorTintColor = .black
    }
    
    func addPanGesture() {
        if let swipe = self.panGestureRecognizer {
            self.removeGestureRecognizer(swipe)
            self.panGestureRecognizer = nil
        }
        let panLeftRight = UIPanGestureRecognizer(target: self, action: #selector(didPanLeftRight))
        self.addGestureRecognizer(panLeftRight)
        panLeftRight.delegate = self
        self.panGestureRecognizer = panLeftRight
    }
    
    // Provide relative Index after user scroll the crousel
    func getIndexForScroll(tx: CGFloat) -> Int {
        for index  in 0..<views.count {
            let width = -(CGFloat(index) * self.fullHeight) + self.sideMargin
            let marginWidth = width + CGFloat(index * self.overlapMargion)
            if tx > marginWidth {
                return index
            }
        }
        return 0
    }
    
    @MainActor
    func scrollToIndex(index: Int) { // Function Set Crousel to provided Index
        
        self.pageIndicator.currentPage = index

        UIView.transition(with: self, duration: 1) {
            let width = -(CGFloat(index) * self.halfHeight) + self.sideMargin
            let marginWidth = width + CGFloat(index * self.overlapMargion)
            for i in 0..<self.views.count {
                let translation = CGAffineTransform(translationX: marginWidth, y: 0)
                if i == index {
                    let scaling = CGAffineTransformScale(self.views[i].originTransform, self.zoomFactor, self.zoomFactor)
                    let fullTransform = scaling.concatenating(translation)
                    self.views[i].transform = fullTransform
                    self.views[i].layer.zPosition = 1
                } else  {
                    let scaling = CGAffineTransformScale(self.views[i].originTransform, 1.0, 1.0)
                    let fullTransform = scaling.concatenating(translation)
                    self.views[i].transform = fullTransform//CGAffineTransformScale(self.views[i].originTransform, 1.0, 1.0);
                    self.views[i].layer.zPosition = 0
                }
            }
        }
        self.currentIndex = index
        
    }
    
    var startingPoint: CGPoint?
    var firstTranslation: CGFloat = 0
    @objc func didPanLeftRight(sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: self)
        
        switch sender.state {
        case .began:
            startingPoint = point
            firstTranslation = point.x
        case .changed:
            let current = self.views[0].transform.tx
            let offset = point.x - (startingPoint?.x ?? 0)
            let final = current + offset
            self.startingPoint = point
            let translation = CGAffineTransform(translationX: final, y: 0)
            let diff = point.x - firstTranslation
            let percent = diff / fullHeight
            var scaleX = 0.25*percent
            if scaleX < 0 {
                scaleX = -scaleX
            }
            if point.x > 0 { //swiping right
                if currentIndex == 0 {
                    return
                }
                for i in 0..<views.count {
                    var scaling: CGAffineTransform
                    var fullTransform: CGAffineTransform
                    
                    if i == currentIndex { // reducing size of selected image according to Pan
                        scaling = CGAffineTransformScale(self.views[i].originTransform, zoomFactor - scaleX, zoomFactor - scaleX)
                    } else if i == currentIndex - 1 { // incresing size of previous image according to Pan
                        scaling = CGAffineTransformScale(self.views[i].originTransform, 1 + scaleX, 1 + scaleX)
                    } else {
                        scaling = CGAffineTransformScale(self.views[i].originTransform, 1, 1)
                    }
                    
                    fullTransform = scaling.concatenating(translation)
                    self.views[i].transform = fullTransform

                }
            } else {
                //swiping left
                if currentIndex == (self.views.count - 1) {
                    return
                }
                for i in 0..<views.count {
                    var scaling: CGAffineTransform
                    var fullTransform: CGAffineTransform
                    if i == currentIndex { // reducing size of selected image according to Pan
                        scaling = CGAffineTransformScale(self.views[i].originTransform, zoomFactor - scaleX, zoomFactor - scaleX)
                    } else if i == currentIndex + 1 { // incresing size of next image according to Pan
                        scaling = CGAffineTransformScale(self.views[i].originTransform, 1 + scaleX, 1 + scaleX)
                    } else {
                        scaling = CGAffineTransformScale(self.views[i].originTransform, 1, 1)
                    }
                    fullTransform = scaling.concatenating(translation)
                    self.views[i].transform = fullTransform
                }
            }
            
        case .ended:
            self.scrollToIndex(index: self.getIndexForScroll(tx: self.views[0].transform.tx))
        default:
            break
        }
    }
}

extension CrouselView: UIGestureRecognizerDelegate {
    
}
