//
//  ProdutoViewController.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 14/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//
import UIKit
import SDWebImage

class ProdutoViewController: UIViewController {
    
    @IBOutlet weak var showLoading: UIActivityIndicatorView!
    @IBOutlet weak var imagemProduto: UIImageView!
    @IBOutlet weak var nomeProduto: UILabel!
    @IBOutlet weak var de: UILabel!
    @IBOutlet weak var por: UILabel!
    @IBOutlet weak var descrição: UILabel!
    @IBOutlet weak var btnReservar: UIButton!
    var produto: Produto?
    let serviceProduto = ServiceProduto()
    var estado: Bool = false
    
    
    @IBAction func btnReservarAction(_ sender: Any) {
        reserva()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = produto?.categoria.descricao
        self.btnReservar.layer.cornerRadius = 10
        self.btnReservar.clipsToBounds = true
        carregarImagemProduto()
        validandoEntradas()
        
    }
    
    //validando as entradas e setando os valores na View
    private func validandoEntradas(){
        
        if let nome = self.produto?.nome {
            self.nomeProduto.text = nome
        }
        
        if let de = self.produto?.precoDe {
            let deCortado: NSMutableAttributedString =  NSMutableAttributedString(string: String("De: \(de)"))
            deCortado.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, deCortado.length))
            self.de.attributedText = deCortado
        }
        
        if let por = self.produto?.precoPor {
            if let porArredondado: Double = arredonda(valor: por, casasdecimais: 2){
                self.por.text = String("Por: \(porArredondado)")
            }
        }
        
        if let descrição = self.produto?.descrição {
            self.descrição.text = descrição
        }
        
    }
    
    // esse metodo e chamado SEMRPE que a tela for apresentada ao usuario
    override func viewWillAppear(_ animated: Bool) {
        
        //com esse metodo a gente "esconde" a TabBar da tela
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //Metodo para carregar as imagens de uma URL usando a pod SDWebImage
    //ImageProduto
    private func carregarImagemProduto(){
        
        if let urlRecuperada = self.produto?.urlImagem {
            
            if let url = URL(string: urlRecuperada){
                
                //Aqui é carregada a imagem
                self.imagemProduto.sd_setImage(with: url, completed: nil)
                
            }
            
        }
        
    }
    
    //Faz a reserva e retorna o usuario para Home
    private func reserva(){
        
        self.desabilitaBotão()
        
        self.serviceProduto.fazerReserva(produto: self.produto!) { (estado: Bool) in
            
            self.habilitaBotão()
            
            if estado == true {
                
                self.showSimpleAlert(title: "Reserva confirmada", message: "Sua reserva foi realizada com sucesso", action: { (_) in
                    self.performSegue(withIdentifier: "backToHome", sender: self)
                })
            } else {
                
                //Alerta
                let alertaController = UIAlertController(title: "Erro",
                                                         message: "Sua reserva não pode ser realizada, por favor tente novamente em instantes ou contate nosso atendimento", preferredStyle: .alert)
                
                let acaoOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                //adicionando os botoes ao alerta
                alertaController.addAction(acaoOK)
                
                self.present(alertaController, animated: true, completion: nil)
                self.btnReservar.isEnabled = true
            }
            
        }
        
    }
    
    //Arredonda numero
    func arredonda(valor: Double, casasdecimais: Int)-> Double{
        let formato = String(casasdecimais)+"f"
        return Double(String(format: "%."+formato, valor))!
    }
    
    func desabilitaBotão(){
        self.btnReservar.isEnabled = false
        self.btnReservar.backgroundColor = UIColor(displayP3Red: 0.518, green: 0.518, blue: 0.518, alpha: 1)
        self.showLoading.isHidden = false
        self.showLoading.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func habilitaBotão(){
        self.btnReservar.isEnabled = true
        self.btnReservar.backgroundColor = UIColor(displayP3Red: 0.414, green: 0.244, blue: 0.568, alpha: 1)
        self.showLoading.isHidden = true
        self.showLoading.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
}

extension UIViewController {
    
    func showSimpleAlert(title: String, message: String, action: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: action))
        self.present(alert, animated: true, completion: nil)
    }
    
}
