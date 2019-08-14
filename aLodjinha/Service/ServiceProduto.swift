//
//  ServiceProduto.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 13/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation

class ServiceProduto {
    
    var produtos: [Produto] = []
    
    //Consumindo a API JSON com os dados para carregar no app
    //Neste metodo esta sendo carregado os dados do Banner, não foi feito uma consulta generica porque as estruturas dos dados mudam (banner, categoria e produto) por isso uma consulta por obj
    func consultarMaisVendidos(completionHandler: @escaping (_ result: [Produto]) -> Void){
        
        if let urlRecuperada = URL(string: "https://alodjinha.herokuapp.com/produto/maisvendidos") {
            
            let consulta = URLSession.shared.dataTask(with: urlRecuperada) { (dados, requisicao, erro) in
                
                if erro == nil {
                    
                    if let dadosRetorno = dados{
                        
                        let maisVendidosDecoder = JSONDecoder()
                        
                        do{
                            let data = try maisVendidosDecoder.decode(MaisVendidos.self, from: dadosRetorno)
                            
                            print(data)
                            
                        }catch{
                            print("Erro ao transformar o retorno: \(error.localizedDescription)")
                        }
                        
                    }
                    
                }else{
                    print("Não foi possivel acessar o servidor de dados")
                }
                
            }
            consulta.resume()
            
        }
        
    }
    
}
