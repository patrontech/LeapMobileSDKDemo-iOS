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
    .fullScreenCover(isPresented: $viewModel.isDeepLinkViewPresented) {
      NavigationStack {
        DeeplinkView()
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Button {
                viewModel.isDeepLinkViewPresented = false
              } label: {
                Image(systemName: "xmark")
              }
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
          Button {
            viewModel.closeActiveSheet()
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 14, weight: .bold))
              .foregroundColor(.primary)
              .padding(12)
              .background(.ultraThinMaterial)
              .clipShape(Circle())
              .shadow(radius: 4)
          }
          .padding(.top, 50)
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
        FilterChipButton(title: "Buy Now", isSelected: true) {
          viewModel.openSDK(style: .bottomSheet)
        }
        FilterChipButton(title: "Auction", isSelected: false) {
          viewModel.openSDK(style: .fullScreen)
        }
        FilterChipButton(title: "Premier Auction", isSelected: false) {
          viewModel.openDeepLinkView()
        }
        FilterChipButton(title: "Sold", isSelected: false) {
          viewModel.openSSOWebView()
        }
        
        // POC Demo Controls
        Divider()
          .frame(height: 30)
        
        FilterChipButton(
          title: viewModel.isViewInjectionEnabled ? "💰 Injection ON" : "💰 Injection OFF",
          isSelected: viewModel.isViewInjectionEnabled
        ) {
          viewModel.toggleViewInjection()
        }
        
        FilterChipButton(title: "🔄 Update Balance", isSelected: false) {
          viewModel.simulateBalanceUpdate()
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
