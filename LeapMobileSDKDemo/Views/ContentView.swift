//
//  NewContentView.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 14/01/26.
//
import SwiftUI
import DemoSDK

struct ContentView: View {
  
  @Binding var state: Leap.State
  @Binding var deeplinkToHandle: URL?
  @StateObject private var viewModel = ContentViewModel()
  let products = Product.mock
  
  var body: some View {
    Group {
      if state == .initialized {
        mainContent
      } else {
        ProgressView()
          .progressViewStyle(.circular)
          .controlSize(.large)
      }
    }
    .onOpenURL { url in
      viewModel.handleDeeplink(url, state: state)
    }
    .onChange(of: state) { _, newValue in
      guard newValue == .initialized else { return }
      viewModel.onSDKInitialized()
      viewModel.onAppear()
    }
    .onChange(of: deeplinkToHandle) { _, newValue in
      if let url = newValue {
        viewModel.handleDeeplink(url, state: state)
        deeplinkToHandle = nil
      }
    }
    .fullScreenCover(isPresented: $viewModel.isDeepLinkViewPresented) {
      NavigationStack {
        DeeplinkView()
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              CircularIconButton(
                icon: .assetName("chevron"),
                action: { viewModel.isDeepLinkViewPresented = false },
                backgroundColor: .white,
                iconColor: .blue,
                iconSize: 20,
                padding: 12
              )
            }
          }
      }
    }
    .sheet(item: $viewModel.activeBottomSheet) { sheet in
      sheet.item
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
    .sheet(isPresented: $viewModel.isWebViewPresented) {
      NavigationStack {
        viewModel.openWebView(
          urlString: "https://id.fanatics.com/oauth2/auth?scope=openid&response_type=code&client_id=ficiXzvv9_V95JuAry4yhaKOMHhKG7bXVaoy1335PqOACW24&redirect_uri=https://fanatics-one.com/"
        )
      }
    }
    .fullScreenCover(item: $viewModel.activeFullScreenSheet) { sheet in
      ZStack(alignment: .topLeading) {
        sheet.item
          .ignoresSafeArea()
        
        if viewModel.isAtRootScreen {
          CircularIconButton(
            icon: .systemName("xmark"),
            action: { viewModel.closeActiveSheet() },
            backgroundColor: .white,
            iconColor: .black,
            iconSize: 16,
            padding: 12
          )
          .padding(.top, 8)
          .padding(.leading, 16)
        }
      }
    }
  }
  
  // MARK: - Main Content
  
  private var mainContent: some View {
    NavigationStack {
      VStack(spacing: 12) {
        scrollView
      }
      .navigationBarHidden(true)
    }
  }
  
  // MARK: - ScrollView
  
  private var scrollView: some View {
    ScrollView(.vertical, showsIndicators: false) {
      LazyVStack(spacing: 8) {
        Text("Deeplinks")
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.headline)
          .fontWeight(.bold)
          .padding()
        SampleButton(title: "Deeplink Examples") {
          viewModel.openDeepLinkView()
        }
        Text("Notifications")
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.headline)
          .fontWeight(.bold)
          .padding()
        SampleButton(title: "Schedule") {
          viewModel.sendTestNotification(.rewards)
        }
        SampleButton(title: "Talents") {
          viewModel.sendTestNotification(.events)
        }
        SampleButton(title: "Brands") {
          viewModel.sendTestNotification(.profile)
        }
        SampleButton(title: "Sample") {
          viewModel.sendTestNotification(.sampleApp)
        }
        Text("SSO Cookies")
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.headline)
          .fontWeight(.bold)
          .padding()
        SampleButton(title: "Authentication Webview") {
          viewModel.openSSOWebView()
        }
        Text("Main SDK Features")
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.headline)
          .fontWeight(.bold)
          .padding()
        SampleButton(title: "Start SDK") {
          viewModel.openSDK(style: .bottomSheet)
        }
        SampleButton(title: "Start SDK - Full Screen") {
          viewModel.openSDK(style: .fullScreen)
        }
        SampleButton(title: "Logout SDK") {
          viewModel.logoutUser()
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal)
    }
  }
}
