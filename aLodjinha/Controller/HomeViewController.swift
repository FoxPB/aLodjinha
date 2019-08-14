//
//  HomeViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 07/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet weak var contentView: UIView!
 
    let serviceBanner = ServiceBanner()
    let serviceProduto = ServiceProduto()
    var banners: [Banner] = []
    var imagens: [UIImage] = []
    var produtos: [Produto] = []
    var imagensView: [UIImageView] = []
    var currentViewControllerIndex = 0
    var tempoDoTimeBanners = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView dos MaisVendidos
        //self.setupTableView()
        
        //Logo da Lodjinha que fica na tela home
        self.logoNavigationBar()
        
        //fazendo a consulta no Banco a partir do Service e "poluindo" o mesmo kkkk
        self.serviceBanner.consultarBanner { (banners) in
            self.banners = banners
        }
        
        //fazendo a consulta no Banco a partir do Service
        self.serviceProduto.consultarMaisVendidos { (produtos) in
            self.produtos = produtos
            print(produtos[0])
        }
        
        //Inicializar o Timer
        //Coloquei esse timer para dar tempo da consulta JSON ser feita e preencher o array
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            
            self.tempoDoTimeBanners = self.tempoDoTimeBanners - 1
            
            //caso o timer execute ate o 1
            if self.tempoDoTimeBanners == 1 {
                self.carregarImagemProfile()
            }
            
            //caso o timer execute ate o 0
            if self.tempoDoTimeBanners == 0 {
                timer.invalidate()
                self.configurePageViewController()
            }
        })
        
    }
    
    //Definindo a Table view que sera usada nos MaisVendidos
    let tableview: UITableView = {
        let tableMaisVendidos = UITableView()
        tableMaisVendidos.backgroundColor = UIColor.white
        tableMaisVendidos.translatesAutoresizingMaskIntoConstraints = false
        return tableMaisVendidos
    }()
    
    //Instancia da tableview
    func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(MaisVendidosCelulaTableViewCell.self, forCellReuseIdentifier: "celulaHome")
        
        view.addSubview(tableview)
        
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableview.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableview.leftAnchor.constraint(equalTo: self.view.leftAnchor)
            ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "celulaHome", for: indexPath) as! MaisVendidosCelulaTableViewCell
        cell.backgroundColor = UIColor.white
        return cell
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
        
        self.carregarImagemProfile()
        
        if index >= banners.count || banners.count == 0 {
            return nil
        }
        
        guard let dataBannerViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: DataBannerViewController.self)) as? DataBannerViewController else {
            return nil
        }
        
        dataBannerViewController.index = index
        if imagens.count > 0 {
            dataBannerViewController.linkUrl = self.banners[index].linkUrl
            dataBannerViewController.image = self.imagens[index]
        }
        
        return dataBannerViewController
    }
    
    //Metodo para carregar as imagens de uma URL usando a pod SDWebImage
    private func carregarImagemProfile(){
        
        if self.banners.count > 0 {
            
            self.imagens = []
            
            for i in 0..<self.banners.count{
                
                if let url = URL(string: self.banners[i].urlImagem){
                    
                    //Aqui é carregada a imagem
                    let imageView = UIImageView()
                    imageView.sd_setImage(with: url) { (image, erro, cache, url) in
                        
                        self.imagens.append(image!)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
}

//Controle da PageView
extension HomeViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewCOntroller: UIPageViewController) -> Int {
        return banners.count
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
        
        if currentIndex == banners.count {
            return nil
        }
        
        currentIndex += 1
        
        currentViewControllerIndex = currentIndex
        
        return detailViewControllerAt(index: currentIndex)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)  {
        
        if completed {
            if let currentViewController = pageViewController.viewControllers![0] as? DataBannerViewController {
                //pageControl.currentPage =
               
                //self.detailViewControllerAt.currentPageIndex = pageViewController.viewControllers!.first!.view.tag
                print("Completd")
            }
        }
        
    }
    
    
    
}
