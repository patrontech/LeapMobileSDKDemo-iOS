//
//  NewContentView.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 14/01/26.
//
import SwiftUI
import LeapMobile

struct ContentView: View {
  
  @Binding var initialization: LeapMobileSDK.Initialization
  @Binding var deeplinkToHandle: URL?
  @StateObject private var viewModel = ContentViewModel()
  let products = Product.mock
  
  var body: some View {
    Group {
      if initialization == .initialized {
        mainContent
      } else {
        ProgressView()
          .progressViewStyle(.circular)
          .controlSize(.large)
      }
    }
    .onOpenURL { url in
      viewModel.handleDeeplink(url, initialization: initialization)
    }
    .onChange(of: deeplinkToHandle) { _, newValue in
      if let url = newValue {
        viewModel.handleDeeplink(url, initialization: initialization)
        deeplinkToHandle = nil
      }
    }
    .fullScreenCover(isPresented: $viewModel.isDeepLinkViewPresented, onDismiss: {
      viewModel.restoreSDKState()
    }) {
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
            icon: .assetName("chevron"),
            action: { viewModel.closeActiveSheet() }
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
        header
        filters
        productList
      }
      .navigationBarHidden(true)
    }
  }
  
  // MARK: - Header
  
  private var header: some View {
    HStack {
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.gray)
        Text("Search")
          .foregroundColor(.gray)
        Spacer()
      }
      .padding(10)
      .background(Color(.systemGray6))
      .cornerRadius(12)
      
      Button {
      } label: {
        Text("Search")
          .fontWeight(.semibold)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(Color.green)
          .foregroundColor(.black)
          .cornerRadius(16)
      }
    }
    .padding(.horizontal)
  }
  
  // MARK: - Filters
  
  private var filters: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        FilterChipButton(title: "Open SDK", isSelected: true) {
          viewModel.openSDK(style: .bottomSheet)
        }
        FilterChipButton(title: "Logout", isSelected: false) {
          viewModel.logoutUser()
        }
        FilterChipButton(title: "Deeplink", isSelected: false) {
          viewModel.openDeepLinkView()
        }
        FilterChipButton(title: "SSOWebView", isSelected: false) {
          viewModel.openSSOWebView()
        }
        FilterChipButton(title: "Open SDK Full", isSelected: false) {
          viewModel.openSDK(style: .fullScreen)
        }
        
        // Notification test buttons
        FilterChipButton(title: "🔔 Schedule", isSelected: false) {
          viewModel.sendTestNotification(.rewards)
        }
        FilterChipButton(title: "🔔 Talents", isSelected: false) {
          viewModel.sendTestNotification(.events)
        }
        FilterChipButton(title: "🔔 Brands", isSelected: false) {
          viewModel.sendTestNotification(.profile)
        }
        FilterChipButton(title: "🔔 Sample", isSelected: false) {
          viewModel.sendTestNotification(.sampleApp)
        }
      }
      .padding(.horizontal)
    }
  }
  
  // MARK: - Product List
  
  private var productList: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        ForEach(products) { product in
          ProductCard(product: product)
        }
      }
      .padding(.horizontal)
      .padding(.bottom, 20)
    }
  }
}
