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

struct Produtos: Codable {
    let data: [Produto]
    let offset, total: Int
}

struct Produto: Codable {
    
    var descrição: String?
    var id: Int
    var nome: String
    var precoDe: Double
    var precoPor: Double
    var urlImagem: String
    var categoria: Categoria
    
}
