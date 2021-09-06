//
//  Shop.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/02.
//

import Foundation

struct Shop: Codable {
    let name: String
    let location: String
    let createdAt: String
    let documentID: String
    let foods: [Food]
}
