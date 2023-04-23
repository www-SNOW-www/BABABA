//
//  Shoe.swift
//  BABABA
//
//  Created by Snow on 2023/02/24.
//

import SwiftUI

// MARK: Coffee Model With Sample Data
struct Shoe: Identifiable {
    var id: UUID = .init()
    var imageName: String
    var title: String
    var price: String
}

var shoe: [Shoe] = [
    .init(imageName: "Shoe1", title: "Jordan Stay Loyal 2", price: "¥13,750"),
    .init(imageName: "Shoe2", title: "Lebron XX Christmas EP", price: "¥25,300"),
    .init(imageName: "Shoe3", title: "Lebron XX SE", price: "¥18,700"),
    .init(imageName: "Shoe4", title: "Jordan WhyNot.6 PF", price: "¥16,500"),
    .init(imageName: "Shoe5", title: "NikeAir Zoom G.T.Jump", price: "¥24,200"),
]
