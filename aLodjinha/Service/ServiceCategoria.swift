//
//  ServiceCategoria.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 15/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation

class ServiceCategoria {
    
    var categorias: [Categoria] = []
    
    //Consumindo a API JSON com os dados para carregar no app
    //Neste metodo esta sendo carregado os dados da Categoria, não foi feito uma consulta generica porque as estruturas dos dados mudam (banner, categoria e produto) por isso uma consulta por obj
    func consultarCategoria(completionHandler: @escaping (_ result: [Categoria]) -> Void){
        
        if let urlRecuperada = URL(string: "https://alodjinha.herokuapp.com/categoria") {
            
            let consulta = URLSession.shared.dataTask(with: urlRecuperada) { (dados, requisicao, erro) in
                
                if erro == nil {
                    
                    if let dadosRetorno = dados{
                        
                        let categoriasDecoder = JSONDecoder()
                        
                        do{
                            
                            let categorias = try categoriasDecoder.decode(Categorias.self, from: dadosRetorno)
                            
                            self.categorias = categorias.data
                            completionHandler(self.categorias)
                            
                        }catch{
                            print("Erro ao transformar o retorno de Categorias: \(error.localizedDescription)")
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
