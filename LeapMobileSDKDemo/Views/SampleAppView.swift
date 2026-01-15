import SwiftUI

struct SampleAppView: View {
  
  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    VStack(spacing: 20) {
      
      Text("Auction")
        .font(.title)
        .fontWeight(.bold)
      
      Button {
        openDeeplink()
      } label: {
        Text("Open URL")
          .font(.system(size: 18, weight: .medium))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
  }
  
  private func openDeeplink() {
    dismiss()
    guard let url = URL(string: "fanaticssdkstaging://schedule") else { return }
    openURL(url)
  }
}
