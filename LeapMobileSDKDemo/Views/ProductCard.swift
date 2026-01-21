//
//  ProductCard.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 15/01/26.
//

import SwiftUI

struct ProductCard: View {
  let product: Product
  
  var body: some View {
    HStack(spacing: 12) {
      
      // Image placeholder
      Rectangle()
        .fill(Color(.systemGray5))
        .frame(width: 80, height: 120)
        .cornerRadius(8)
        .overlay(
          Image(product.image)
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
        )
      
      VStack(alignment: .leading, spacing: 6) {
        
        Text(product.title)
          .font(.subheadline)
          .fontWeight(.semibold)
          .lineLimit(3)
        
        HStack(spacing: 8) {
          Text(product.price)
            .font(.title3)
            .fontWeight(.bold)
          
          Text("Good Deal")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .cornerRadius(8)
        }
        
        Text(product.subtitle)
          .font(.caption)
          .foregroundColor(.gray)
        
        Spacer()
        
        HStack {
          Button(action: {}) {
            Text("Add to cart")
              .font(.subheadline)
              .fontWeight(.semibold)
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
              .background(Color.black)
              .foregroundColor(.white)
              .cornerRadius(20)
          }
          
          Spacer()
          
          HStack(spacing: 4) {
            Image(systemName: "heart")
            Text("\(product.favorites)")
          }
          .foregroundColor(.gray)
          .font(.caption)
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
  }
}
