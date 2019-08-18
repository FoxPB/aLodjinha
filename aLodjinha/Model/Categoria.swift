//
//  Categoria.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 12/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation

struct Categorias: Codable {
    let data: [Categoria]
}

struct Categoria: Codable {
    
    var id: Int
    var descricao: String?
    var urlImagem: String?
    
}
