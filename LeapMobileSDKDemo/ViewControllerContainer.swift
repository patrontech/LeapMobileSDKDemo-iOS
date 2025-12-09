//
//  ViewControllerContainer.swift
//  LeapMobileSDKDemo
//
//  Created by Gregory Higley on 2025-12-08.
//

import SwiftUI

struct ViewControllerContainer: UIViewControllerRepresentable {
  let controller: UIViewController

  init(_ controller: UIViewController) {
    self.controller = controller
  }
  
  func makeUIViewController(context: Context) -> UIViewController {
    controller
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct Sheet: Identifiable {
  let item: ViewControllerContainer
  let id = UUID()
  
  init(_ controller: UIViewController) {
    item = ViewControllerContainer(controller)
  }
}

