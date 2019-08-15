//
//  HomeViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 07/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categoriaCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
 
    let serviceBanner = ServiceBanner()
    let serviceProduto = ServiceProduto()
    var banners: [Banner] = []
    var imagensBanners: [UIImage] = []
    var produtosMaisVendidos: [Produto] = []
    var imagensProdutosMaisVendidos: [UIImage] = []
    var currentViewControllerIndex = 0
    var tempoDoTimeBanners = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //Logo da Lodjinha que fica na tela home
        self.logoNavigationBar()
        
        //fazendo a consulta no Banco a partir do Service e "poluindo" o mesmo kkkk
        self.serviceBanner.consultarBanner { (banners) in
            self.banners = banners
        }
        
        //fazendo a consulta no Banco a partir do Service
        self.serviceProduto.consultarMaisVendidos { (produtos) in
            
            self.produtosMaisVendidos = produtos
            
            print(produtos[0])
        }
        
        //Inicializar o Timer
        //Coloquei esse timer para dar tempo da consulta JSON ser feita e preencher o array
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            
            self.tempoDoTimeBanners = self.tempoDoTimeBanners - 1
            
            //caso o timer execute ate o 1
            if self.tempoDoTimeBanners == 1 {
                self.carregarImagensBanners()
                self.carregarImagensMaisVendidos()
            }
            
            //caso o timer execute ate o 0
            if self.tempoDoTimeBanners == 0 {
                timer.invalidate()
                self.configurePageViewController()
                //atualizando a tabela... porque muito provalvelmente o JSON nao vai ter carregado os dados ainda
                self.tableView.reloadData()
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if produtosMaisVendidos.count < 1 {
            return 0
        }
        
        return produtosMaisVendidos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        carregarImagensMaisVendidos()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celulaHome", for: indexPath) as! MaisVendidosCelulaTableViewCell
        
        cell.nomeProduto.text = produtosMaisVendidos[indexPath.row].nome
        
        let deCortado: NSMutableAttributedString =  NSMutableAttributedString(string: String("De: \(produtosMaisVendidos[indexPath.row].precoDe)"))
        deCortado.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, deCortado.length))
        
        cell.de.attributedText = deCortado
        
        if let porArredondado: Double = arredonda(valor: produtosMaisVendidos[indexPath.row].precoPor, casasdecimais: 2){
            cell.por.text = String("Por: \(porArredondado)")
        }
        
        if self.imagensProdutosMaisVendidos.count == produtosMaisVendidos.count {
             cell.imageProdutoMaisVendido.image = self.imagensProdutosMaisVendidos[indexPath.row]
        }
        
        return cell
    }
    
    //metodo que recupera o produto selecionado
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let produto = produtosMaisVendidos[indexPath.row]
        
        self.performSegue(withIdentifier: "homeParaProduto", sender: produto)
        
    }
    
    //metodo usado para setar os dados na outra "tela" classe
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //tratando para saber se o indetificador da segue esta certo
        if segue.identifier == "homeParaProduto" {
            let produtoViewController = segue.destination as! ProdutoViewController
            produtoViewController.produto = sender as? Produto
        }
    
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
        
        self.carregarImagensBanners()
        
        if index >= banners.count || banners.count == 0 {
            return nil
        }
        
        guard let dataBannerViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: DataBannerViewController.self)) as? DataBannerViewController else {
            return nil
        }
        
        dataBannerViewController.index = index
        if imagensBanners.count == banners.count {
            dataBannerViewController.linkUrl = self.banners[index].linkUrl
            dataBannerViewController.image = self.imagensBanners[index]
        }
        
        return dataBannerViewController
    }
    
    //Metodo para carregar as imagens de uma URL usando a pod SDWebImage
    //Banners
    private func carregarImagensBanners(){
        
        if self.banners.count > 0 {
            
            self.imagensBanners = []
            
            for i in 0..<self.banners.count{
                
                if let url = URL(string: self.banners[i].urlImagem){
                    
                    //Aqui é carregada a imagem
                    let imageView = UIImageView()
                    imageView.sd_setImage(with: url) { (image, erro, cache, url) in
                        
                        self.imagensBanners.append(image!)
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    //Metodo para carregar as imagens de uma URL usando a pod SDWebImage
    //MaisVendidos
    private func carregarImagensMaisVendidos(){
        
        if self.produtosMaisVendidos.count > 0 {
            
            self.imagensProdutosMaisVendidos = []
            
            for i in 0..<self.produtosMaisVendidos.count{
                
                if let url = URL(string: self.produtosMaisVendidos[i].urlImagem){
                    
                    //Aqui é carregada a imagem
                    let imageView = UIImageView()
                    imageView.sd_setImage(with: url) { (image, erro, cache, url) in
                        
                        self.imagensProdutosMaisVendidos.append(image!)
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    //Arredonda numero
    func arredonda(valor: Double, casasdecimais: Int)-> Double{
        let formato = String(casasdecimais)+"f"
        return Double(String(format: "%."+formato, valor))!
    }
    
    // esse metodo e chamado SEMRPE que a tela for apresentada ao usuario
    override func viewWillAppear(_ animated: Bool) {
        
        self.carregarImagensBanners()
        self.carregarImagensMaisVendidos()
        //com esse metodo a gente "esconde" a TabBar da tela
        self.tabBarController?.tabBar.isHidden = false
        
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
