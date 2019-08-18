//
//  ProdutoTableViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 15/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit

class ProdutoTableViewController: UITableViewController {

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
                
                var index = 0
                while index < self.limite {
                    self.produtosDaCategoriaLimite.append(self.produtosDaCategoria[index])
                    index += 1
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


    override func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.carregarImagens()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celulaProduto", for: indexPath) as! ProdutoCell
        
        cell.nomeProduto.text = produtosDaCategoriaLimite[indexPath.row].nome
        
        let deCortado: NSMutableAttributedString =  NSMutableAttributedString(string: String("De: \(produtosDaCategoriaLimite[indexPath.row].precoDe)"))
        deCortado.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, deCortado.length))
        
        cell.de.attributedText = deCortado
        
        if let porArredondado: Double = arredonda(valor: produtosDaCategoriaLimite[indexPath.row].precoPor, casasdecimais: 2){
            cell.por.text = String("Por: \(porArredondado)")
        }
        
        /*
        let image: UIImage? = self.imagensProduto[indexPath.row]
        if image != nil {
            cell.imageProduto.image = image
        }*/
 
        //Deixei com esta imagem porque não consegui ajeitar o bug
        //Amanha vou tentar concerta to morto... travei
        cell.imageProduto.image = #imageLiteral(resourceName: "Foto indisponivel")
    
        return cell
    }
    
    //Metodo que captura a celula selecionada
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let produto = produtosDaCategoriaLimite[indexPath.row]
        
        self.performSegue(withIdentifier: "categoriaParaProduto", sender: produto)
    }
    
    //Metodo que vai fazer o load quanto o usuario alcançar 0 limite de itens permitido
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.produtosDaCategoriaLimite.count - 1 {
            if self.produtosDaCategoriaLimite.count < self.produtosDaCategoria.count {
                
                var index = self.produtosDaCategoriaLimite.count
                self.limite = index + 20
                if self.produtosDaCategoria.count < self.limite {
                    self.limite = self.produtosDaCategoria.count
                }
                
                while index < self.limite {
                    self.produtosDaCategoriaLimite.append(self.produtosDaCategoria[index])
                    index = index + 1
                }
                self.perform(#selector(loadTable), with: nil, afterDelay: 1.5)
            }
        }
        
    }
    
    @objc func loadTable() {
        self.tableView.reloadData()
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
            
            //tem um bug aqui onde o numero de fotos carregadas é 23 e o numero de produtos 25
            //com o avançar da hora ontem e tantas tentativas eu travei, por isso resolvi mandar assim para não atrasar o projeto
            //mas não esta quebrando eu deixei dando GET em um foto estatica la no datatable
            var cont1 = 0
            var cont2 = 0
            var cont3 = 0
            var cont4 = 0
            var cont5 = 0
            
            for i in 0..<self.produtosDaCategoriaLimite.count{
                
                cont1 += 1
                
                if imagensProduto.count < i-1 {
                    
                    cont2 += 1
                    let semImagem = #imageLiteral(resourceName: "Foto indisponivel")
                    self.imagensProduto.append(semImagem)
                    
                }else{
                    cont3 += 1
                    if let url = URL(string: self.produtosDaCategoriaLimite[i].urlImagem){
                        cont4 += 1
                        //Aqui é carregada a imagem
                        let imageView = UIImageView()
                        imageView.sd_setImage(with: url) { (image, erro, cache, url) in
                            
                            cont5 += 1
                            
                            if let imageRecuperada = image {
                                self.imagensProduto.append(imageRecuperada)
                            }else{
                                
                                let semImagem = #imageLiteral(resourceName: "Foto indisponivel")
                                self.imagensProduto.append(semImagem)
                            }
                            
                        }
                        
                    }else{
                        let semImagem = #imageLiteral(resourceName: "Foto indisponivel")
                        self.imagensProduto.append(semImagem)
                    }
                    
                }

            }
            
            print("Cont1 \(cont1)")
            print("Cont2 \(cont2)")
            print("Cont3 \(cont3)")
            print("Cont4 \(cont4)")
            print("Cont5 \(cont5)")
            print("Tamanho do array de imagens \(self.imagensProduto.count)")
            print("tamanho do produtoDasCategoria \(self.produtosDaCategoria.count)")
            print("tamanho do produtoDasCategoriaLimite \(self.produtosDaCategoriaLimite.count)")
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
