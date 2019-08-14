//
//  Produto.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 12/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation
import UIKit

struct MaisVendidos: Codable {
    let data: [Produto]
}

struct Produto: Codable {
    
    var descrição: String
    var id: Int
    var nome: String
    var precoDe: Int
    var precoPor: Int
    var urlImagem: String
    var categoria: Categoria
    var offset: Int?
    var total: Int?
    
}
