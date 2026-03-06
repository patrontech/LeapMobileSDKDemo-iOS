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
  @Binding var deeplinkToHandle: URL?

  var body: some View {
    ContentView(
      initialization: $initialization,
      deeplinkToHandle: $deeplinkToHandle
    )
  }
}
