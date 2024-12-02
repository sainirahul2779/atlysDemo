//
//  CrouselItemView.swift
//  AtlysTask
//
//  Created by Rahul on 29/11/24.
//

import UIKit

class CrouselItemView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    var leadingConstraint: NSLayoutConstraint?
    var originTransform: CGAffineTransform!

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10
        self.imageView.layer.cornerRadius = 10
        self.imageView.clipsToBounds = true
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
    }
    
    func setData(item: UIImage?) {
        self.imageView.image = item
    }
}
