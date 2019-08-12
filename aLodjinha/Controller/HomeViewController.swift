//
//  HomeViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 07/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    var banners: [Banner] = []
    let dataSource = ["Teste 1", "Teste 2", "Teste 3"]
    var currentViewControllerIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fazendo a consulta no Banco a partir do Service e "poluindo"
        let serviceBanner = ServiceBanner()
        serviceBanner.consultarBanner { (banners) in
            self.banners = banners
            
        }
    
        logoNavigationBar()
        self.configurePageViewController()
        
    }
    
    //Setando a Imagem da NavigationBar
    private func logoNavigationBar(){
        let logo = #imageLiteral(resourceName: "logoNavbar_2")
        let logoView = UIImageView(image: logo)
        self.navigationItem.titleView = logoView
    }
    
    //Configurando a Page View Controler que sera usada como banner
    private func configurePageViewController(){
        
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: CustomPageViewController.self)) as? CustomPageViewController else {
            return
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        pageViewController.view.backgroundColor = UIColor.white
        
        contentView.addSubview(pageViewController.view)
        
        let views: [String: Any] = ["pageView": pageViewController.view]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|",
                                                                  options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                  metrics: nil,
                                                                  views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|",
                                                                  options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                  metrics: nil,
                                                                  views: views))
        
        guard let startingViewController = detailViewControllerAt(index: currentViewControllerIndex) else {
            return
        }
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true)
        
    }
    
    //Definindo o banner
    func detailViewControllerAt(index: Int) -> DataBannerViewController? {
        
        if index >= dataSource.count || dataSource.count == 0 {
            return nil
        }
        
        guard let dataBannerViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: DataBannerViewController.self)) as? DataBannerViewController else {
            return nil
        }
        
        dataBannerViewController.index = index
        print("print no HomeView \(banners)")
        dataBannerViewController.displayText = dataSource[index]
        
        return dataBannerViewController
    }

}


extension HomeViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewCOntroller: UIPageViewController) -> Int {
        return dataSource.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let dataBannerViewController = viewController as? DataBannerViewController
        
        guard var currentIndex = dataBannerViewController?.index else {
            return nil
        }
        
        currentViewControllerIndex = currentIndex
        
        if currentIndex == 0 {
            return nil
        }
        
        currentIndex -= 1
        
        return detailViewControllerAt(index: currentIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let dataBannerViewController = viewController as? DataBannerViewController
        
        guard var currentIndex = dataBannerViewController?.index else {
            return nil
        }
        
        if currentIndex == dataSource.count {
            return nil
        }
        
        currentIndex += 1
        
        currentViewControllerIndex = currentIndex
        
        return detailViewControllerAt(index: currentIndex)
        
    }
    
}
