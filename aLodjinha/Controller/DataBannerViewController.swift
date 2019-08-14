//
//  DataBannerViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 10/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit

class DataBannerViewController: UIViewController {
    
    var image: UIImage?
    var linkUrl: String?
    var index: Int?
    @IBOutlet weak var btnBanner: UIButton!
    
    @IBAction func btnBannerAction(_ sender: Any) {
        
        if let url = URL(string: self.linkUrl!){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageR = image {
            btnBanner.setImage(imageR, for: .normal)
        }
        
    }
    
}
