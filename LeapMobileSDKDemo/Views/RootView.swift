//
//  RootView.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 15/01/26.
//

import LeapMobile
import SwiftUI

struct RootView: View {

  @Binding var initialization: LeapMobileSDK.Initialization

  var body: some View {
    ContentView(initialization: $initialization)
  }
}
