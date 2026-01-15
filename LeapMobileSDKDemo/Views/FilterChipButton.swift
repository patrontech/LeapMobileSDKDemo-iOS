//
//  FilterChipButton.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 15/01/26.
//

import SwiftUI

struct FilterChipButton: View {
  
  let title: String
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline)
        .fontWeight(.medium)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(isSelected ? Color.black : Color(.systemGray5))
        .foregroundColor(isSelected ? .white : .black)
        .cornerRadius(20)
    }
    .buttonStyle(.plain)
  }
}
