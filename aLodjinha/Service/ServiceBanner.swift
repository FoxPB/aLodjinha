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
    func consultarBanner() -> [Banner]{
        
        if let urlRecuperada = URL(string: "https://alodjinha.herokuapp.com/banner") {
            
            let consulta = URLSession.shared.dataTask(with: urlRecuperada) { (dados, requisicao, erro) in
                
                if erro == nil {
                    
                    if let dadosRetorno = dados{
                        
                        do{
                            if let objetoJson = try JSONSerialization.jsonObject(with: dadosRetorno, options: []) as? [String: [AnyObject]] {
                                
                                if let data = objetoJson["data"]{
                                    
                                    for i in 0..<data.count{
                                        
                                        if let banner: AnyObject = data[i]{
                                            
                                            if let id = banner["id"] {
                                                if let linkUrl = banner["linkUrl"]{
                                                    if let urlImage = banner["urlImage"]{
                                                        
                                                        let banner = Banner(id: id as! Int, linkUrl: linkUrl as! String, urlImage: urlImage as! String)
                                                        
                                                        self.banners.append(banner)
                                                        
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                
                            }
                        }catch{
                            print("Erro ao transformar o retorno")
                        }
                        
                    }
                    
                }else{
                    print("Não foi possivel acessar o servidor de dados")
                }
                
            }
            consulta.resume()
        }
        return self.banners
    }
    
    
}
