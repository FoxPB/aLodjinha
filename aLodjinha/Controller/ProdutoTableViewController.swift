//
//  ProdutoTableViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 15/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit

class ProdutoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var showLoading: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    let serviceProduto = ServiceProduto()
    var todosOsProdutos: [Produto] = []
    var produtosDaCategoria: [Produto] = []
    var produtosDaCategoriaLimite: [Produto] = []
    var imagensProduto: [UIImage] = []
    var categoria: Categoria? = nil
    var tempoDoTimeConsulta = 3
    var tempoDoTimeTableView = 12
    var limite = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.isHidden = true
        self.showLoading.isHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationItem.title = categoria?.descricao
        
        //fazendo a consulta no Banco a partir do Service
        self.serviceProduto.consultarProdutos{ (produtos) in
            self.todosOsProdutos = produtos
        }
        
        //Inicializar o Timer
        //Coloquei esse timer para dar tempo da consulta JSON ser feita e preencher o array
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            
            self.tempoDoTimeConsulta = self.tempoDoTimeConsulta - 1
            
            //caso o timer execute ate o 1
            if self.tempoDoTimeConsulta == 1 {
                
                for i in 0..<self.todosOsProdutos.count{
                    if self.todosOsProdutos[i].categoria.id == self.categoria!.id {
                        self.produtosDaCategoria.append(self.todosOsProdutos[i])
                    }
                }
                
                if self.produtosDaCategoria.count > 0 {
                    
                    self.tableView.isHidden = false
                    var index = 0
                    while index < self.limite {
                        self.produtosDaCategoriaLimite.append(self.produtosDaCategoria[index])
                        index += 1
                    }
                }
                
                self.carregarImagens()
                
            }
            
            //caso o timer execute ate o 0
            if self.tempoDoTimeConsulta == 0 {
                timer.invalidate()
                //atualizando a tabela e a collection... porque muito provalvelmente o JSON nao vai ter carregado os dados ainda
                self.tableView.reloadData()
               
            }
        })

    }


    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.produtosDaCategoria.count < 1 {
            
            //Inicializar o Timer
            //Coloquei esse timer para dar tempo da consulta JSON ser feita e preencher o array
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                
                self.tempoDoTimeTableView = self.tempoDoTimeTableView - 1
                
                //caso o timer execute ate o 0
                if self.tempoDoTimeTableView == 0 {
                    timer.invalidate()
                   
                    if self.produtosDaCategoriaLimite.count < 1{
                        //Alerta
                        let alertaController = UIAlertController(title: "Categoria sem produtos",
                                                                 message: "Volte outra vez mais tarde :)", preferredStyle: .alert)
                        
                        let acaoOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
                        //adicionando os botoes ao alerta
                        alertaController.addAction(acaoOK)
                        
                        self.present(alertaController, animated: true, completion: nil)
                    }
                    
                }
            })
            
            return 0
            
        }
        
        return self.produtosDaCategoriaLimite.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.carregarImagens()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celulaProduto", for: indexPath) as! ProdutoCell
        
        cell.nomeProduto.text = produtosDaCategoriaLimite[indexPath.row].nome
        
        let deCortado: NSMutableAttributedString =  NSMutableAttributedString(string: String("De: \(produtosDaCategoriaLimite[indexPath.row].precoDe)"))
        deCortado.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, deCortado.length))
        
        cell.de.attributedText = deCortado
        
        if let porArredondado: Double = arredonda(valor: produtosDaCategoriaLimite[indexPath.row].precoPor, casasdecimais: 2){
            cell.por.text = String("Por: \(porArredondado)")
        }
        
        cell.imageProduto.image = self.imagensProduto[indexPath.row]
        
        return cell
    }
    
    //Metodo que captura a celula selecionada
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let produto = produtosDaCategoriaLimite[indexPath.row]
        
        self.performSegue(withIdentifier: "categoriaParaProduto", sender: produto)
    }
    
    //Metodo que vai fazer o load quanto o usuario alcançar 0 limite de itens permitido
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.produtosDaCategoriaLimite.count - 1 {
            if self.produtosDaCategoriaLimite.count < self.produtosDaCategoria.count {
                
                self.showLoading.isHidden = false
                self.showLoading.startAnimating()
                
                var index = self.produtosDaCategoriaLimite.count
                self.limite = index + 20
                if self.produtosDaCategoria.count < self.limite {
                    self.limite = self.produtosDaCategoria.count
                }
                
                while index < self.limite {
                    self.produtosDaCategoriaLimite.append(self.produtosDaCategoria[index])
                    index = index + 1
                }
                self.perform(#selector(loadTable), with: nil, afterDelay: 1.0)
            }
        }
        
    }
    
    @objc func loadTable() {
        self.tableView.reloadData()
        self.showLoading.isHidden = true
        self.showLoading.stopAnimating()
    }
    
    //metodo usado para setar os dados na outra "tela" classe
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //tratando para saber se o indetificador da segue esta certo
        if segue.identifier == "categoriaParaProduto" {
            
            let produtoViewController = segue.destination as! ProdutoViewController
            produtoViewController.produto = sender as? Produto
            
        }
        
    }
    
    //Metodo para carregar as imagens de uma URL usando a pod SDWebImage
    //Produtos
    private func carregarImagens(){
        
        if self.produtosDaCategoriaLimite.count > 0 {
            
            self.imagensProduto = []
            
            for i in 0..<self.produtosDaCategoriaLimite.count{
                
                if let url = URL(string: self.produtosDaCategoriaLimite[i].urlImagem){
                   
                    //Aqui é carregada a imagem
                    let imageView = UIImageView()
                    imageView.sd_setImage(with: url) { (image, erro, cache, url) in
                        
                        if let imageRecuperada = image {
                            self.imagensProduto.append(imageRecuperada)
                        }
                        
                    }
                    
                }
                
                
                if self.imagensProduto.count == i {
                    let semImagem = #imageLiteral(resourceName: "Foto indisponivel")
                    self.imagensProduto.append(semImagem)
                }
                
            }
            
        }
    }
    
    // esse metodo e chamado SEMRPE que a tela for apresentada ao usuario
    override func viewWillAppear(_ animated: Bool) {
        
        //com esse metodo a gente "esconde" a TabBar da tela
        self.tabBarController?.tabBar.isHidden = true
    }

    //Arredonda numero
    func arredonda(valor: Double, casasdecimais: Int)-> Double{
        let formato = String(casasdecimais)+"f"
        return Double(String(format: "%."+formato, valor))!
    }

}
