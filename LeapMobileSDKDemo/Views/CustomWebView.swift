import SwiftUI
import WebKit

struct CustomWebView: UIViewRepresentable {
  let url: URL
  let dataStore: WKWebsiteDataStore
  
  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    config.websiteDataStore = dataStore
    
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.uiDelegate = context.coordinator
    webView.load(URLRequest(url: url))
    return webView
  }
  
  func makeCoordinator() -> WebViewCoordinator {
      WebViewCoordinator()
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {
  }
}

class WebViewCoordinator: NSObject, WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
