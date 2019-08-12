//
//  DataBannerViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 10/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit

class DataBannerViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    var displayText: String?
    var index: Int?
    var banner: Banner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLabel.text = displayText
    }
    
}
