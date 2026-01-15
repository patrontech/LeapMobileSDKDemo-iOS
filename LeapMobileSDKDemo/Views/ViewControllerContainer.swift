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
    let container = UIViewController()
    container.addChild(controller)
    container.view.addSubview(controller.view)
    controller.view.frame = container.view.bounds
    controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    controller.didMove(toParent: container)
    return container
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

