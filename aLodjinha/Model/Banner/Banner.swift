//
//  Banner.swift
//  aLodjinha
//
//  Created by Ricardo Caldeira on 12/08/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation

struct Banner {

    var id: Int
    var linkUrl: String
    var urlImagem: String
    
    init(id: Int, linkUrl: String, urlImagem: String) {
        self.id = id
        self.linkUrl = linkUrl
        self.urlImagem = urlImagem
    }
    
}
