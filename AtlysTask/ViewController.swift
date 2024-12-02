//
//  ViewController.swift
//  AtlysTask
//
//  Created by Rahul on 29/11/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var crouselContainer: UIView!
    
    var crouselView: CrouselView?
    var items: [UIImage?] = [UIImage(imageLiteralResourceName: "item1") ,UIImage(imageLiteralResourceName: "item2") ,UIImage(imageLiteralResourceName: "item3"), UIImage(imageLiteralResourceName: "item4"), UIImage(imageLiteralResourceName: "item5")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCrouselView()
    }
    
    func setupCrouselView() {
        crouselView = Bundle.main.loadNibNamed("CrouselView", owner: nil, options: nil)?.first as? CrouselView
        if let v = crouselView {
            self.crouselContainer.addSubview(v)
        }
        crouselView?.translatesAutoresizingMaskIntoConstraints = false
        crouselView?.topAnchor.constraint(equalTo: self.crouselContainer.topAnchor).isActive = true
        crouselView?.bottomAnchor.constraint(equalTo: self.crouselContainer.bottomAnchor).isActive = true
        crouselView?.leftAnchor.constraint(equalTo: self.crouselContainer.leftAnchor).isActive = true
        crouselView?.rightAnchor.constraint(equalTo: self.crouselContainer.rightAnchor).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.crouselView?.additems(items: items)

    }

}


