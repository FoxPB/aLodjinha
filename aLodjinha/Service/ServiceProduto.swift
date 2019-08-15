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
                            let maisVendidos = try maisVendidosDecoder.decode(MaisVendidos.self, from: dadosRetorno)
                            
                            self.produtos = maisVendidos.data
                            completionHandler(self.produtos)
                            
                        }catch{
                            print("Erro ao transformar o retorno de MaisVendidos: \(error.localizedDescription)")
                        }
                        
                    }
                    
                }else{
                    print("Não foi possivel acessar o servidor de dados")
                }
                
            }
            consulta.resume()
            
        }
        
    }
    
    func fazerReserva(produto: Produto, completionHandler: @escaping (_ result: Bool) -> Void){
        
        var estado = false
        
        if let urlRecuperada = URL(string: "https://alodjinha.herokuapp.com/produto/\(produto.id)"){
            
            var request = URLRequest(url: urlRecuperada)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(produto.id)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    print ("error: \(error)")
                    DispatchQueue.main.async {
                        completionHandler(estado)
                    }
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                        DispatchQueue.main.async {
                            completionHandler(estado)
                        }
                        print ("server error")
                        return
                }
                
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    
                    print ("got data: \(dataString)")
                    estado = true
                    
                    DispatchQueue.main.async {
                        completionHandler(estado)
                    }

                }
            }//FIM do dataTask
            task.resume()
    
        }//FIM do IF urlRecuperada
        
    }//FIM do metodo fazerReserva
    
}
