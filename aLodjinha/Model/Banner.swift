//
//  Banner.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 12/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation

struct Banners: Codable {
    let data: [Banner]
}

struct Banner: Codable {

    var id: Int
    var linkUrl: String
    var urlImagem: String
    
}
