//
//  Product.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 15/01/26.
//

import Foundation

struct Product: Identifiable {
  let id = UUID()
  let title: String
  let price: String
  let subtitle: String
  let favorites: Int
}

extension Product {
  static let mock: [Product] = [
    Product(
      title: "2018 Finest Refractor Shohei Ohtani ROOKIE #100 PSA 10 GEM MINT",
      price: "$2,199",
      subtitle: "$2,000 offer being considered, act fast",
      favorites: 17
    ),
    Product(
      title: "2021 Pokemon Sword & Shield Evolving Skies Umbreon VMAX #215 PSA 10 GEM MINT",
      price: "$4,000",
      subtitle: "$3,400 offer being considered, act fast",
      favorites: 15
    ),
    Product(
      title: "2022 Topps Gypsy Queen Derek Jeter AUTO /25 PSA 9 MINT",
      price: "$450",
      subtitle: "Offers being negotiated, act fast",
      favorites: 30
    )
  ]
}
