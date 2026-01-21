import SwiftUI

struct DeeplinkItem: Identifiable {
  let id = UUID()
  let title: String
  let url: String
  
  static let schema = "fanaticssdkstaging://"
}

struct SampleAppView: View {
  
  let deeplinks: [DeeplinkItem] = [
    DeeplinkItem(title: "Schedule", url: "\(DeeplinkItem.schema)schedule"),
    DeeplinkItem(title: "Talents", url: "\(DeeplinkItem.schema)talents"),
    DeeplinkItem(title: "Brands", url: "\(DeeplinkItem.schema)brands"),
    DeeplinkItem(title: "Notification Settings", url: "\(DeeplinkItem.schema)notificationSettings"),
    DeeplinkItem(title: "Notification Inbox", url: "\(DeeplinkItem.schema)notificationInbox"),
    DeeplinkItem(title: "Thuzi Registration", url: "\(DeeplinkItem.schema)thuziRegistration"),
    DeeplinkItem(title: "Thuzi Badges", url: "\(DeeplinkItem.schema)huziBadges"),
    DeeplinkItem(title: "Invalid One", url: "\(DeeplinkItem.schema)invalid"),
  ]
  
  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(deeplinks) { deeplink in
            Button {
              openDeeplink(deeplink.url)
            } label: {
              DeeplinkCardView(item: deeplink)
            }
            .buttonStyle(.plain)
          }
        }
        .padding()
      }
    }
    .navigationTitle("Deeplink Tests")
  }
  
  private func openDeeplink(_ urlString: String) {
    dismiss()
    guard let url = URL(string: urlString) else { return }
    openURL(url)
  }
}

struct DeeplinkCardView: View {
  let item: DeeplinkItem
  
  var body: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text(item.title)
          .font(.headline)
        Text(item.url)
          .font(.caption)
          .foregroundColor(.gray)
      }
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .padding()
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}
