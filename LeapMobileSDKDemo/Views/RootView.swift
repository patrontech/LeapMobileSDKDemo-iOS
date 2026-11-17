//
//  RootView.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 15/01/26.
//

import DemoSDK
import SwiftUI

struct RootView: View {

  @Binding var state: Leap.State
  @Binding var deeplinkToHandle: URL?

  var body: some View {
    ContentView(
      state: $state,
      deeplinkToHandle: $deeplinkToHandle
    )
  }
}
