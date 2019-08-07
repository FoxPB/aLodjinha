//
//  HomeViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 07/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        LogoNavigationBar()
        
    }
    
    //
    private func LogoNavigationBar(){
        let logo = #imageLiteral(resourceName: "logoNavbar_2")
        let logoView = UIImageView(image: logo)
        self.navigationItem.titleView = logoView
    }

}
