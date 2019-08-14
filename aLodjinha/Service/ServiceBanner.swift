//
//  ServiceBanner.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 12/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation

class ServiceBanner {
    
    var banners: [Banner] = []
    
    //Consumindo a API JSON com os dados para carregar no app
    //Neste metodo esta sendo carregado os dados do Banner, não foi feito uma consulta generica porque as estruturas dos dados mudam (banner, categoria e produto) por isso uma consulta por obj
    func consultarBanner(completionHandler: @escaping (_ result: [Banner]) -> Void){
        
        if let urlRecuperada = URL(string: "https://alodjinha.herokuapp.com/banner") {
            
            let consulta = URLSession.shared.dataTask(with: urlRecuperada) { (dados, requisicao, erro) in
                
                if erro == nil {
                    
                    if let dadosRetorno = dados{
                        
                        let bannersDecoder = JSONDecoder()
                        
                        do{
                         
                            let banners = try bannersDecoder.decode(Banners.self, from: dadosRetorno)
                            
                            self.banners = banners.data
                            completionHandler(self.banners)
                            
                            
                        }catch{
                            print("Erro ao transformar o retorno de Banners: \(error.localizedDescription)")
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
