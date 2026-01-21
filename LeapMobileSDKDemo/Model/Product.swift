//
//  Product.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 15/01/26.
//

import Foundation

struct Product: Identifiable {
  let id = UUID()
  let image: String
  let title: String
  let price: String
  let subtitle: String
  let favorites: Int
}

extension Product {
  static let mock: [Product] = [
    Product(
      image: "blacklotus",
      title: "1993 Magic The Gathering MTG Unlimited Black Lotus R A BGS 8.5 Mint",
      price: "$48,000",
      subtitle: "Or best offer",
      favorites: 17
    ),
    Product(
      image: "charizard",
      title: "1999 Pokemon Base Set Holo Charizard #4 CGC 9.5 GEM Mint",
      price: "$4,199",
      subtitle: "",
      favorites: 15
    ),
    Product(
      image: "pele",
      title: "1958 Editora Aquarela Soccer Blue Number Pele ROOKIE #10 PSA 4 VGEX",
      price: "$7,750",
      subtitle: "Offers being negotiated, act fast",
      favorites: 30
    )
  ]
}
