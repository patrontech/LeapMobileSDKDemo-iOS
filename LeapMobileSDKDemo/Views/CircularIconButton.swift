import SwiftUI

enum IconSource {
  case systemName(String)
  case assetName(String)
}

struct CircularIconButton: View {
  let icon: IconSource
  let action: () -> Void
  
  var backgroundColor: Color = .white
  var iconColor: Color = .blue
  var iconSize: CGFloat = 20
  var padding: CGFloat = 12
  var shadowRadius: CGFloat = 8
  var shadowOpacity: CGFloat = 0.15
  
  var body: some View {
    Button(action: action) {
      iconImage
        .foregroundColor(iconColor)
        .padding(padding)
        .background(backgroundColor)
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 2)
    }
  }
  
  @ViewBuilder
  private var iconImage: some View {
    switch icon {
    case .systemName(let name):
      Image(systemName: name)
        .font(.system(size: iconSize, weight: .medium))
    case .assetName(let name):
      Image(name)
        .resizable()
        .renderingMode(.template)
        .aspectRatio(contentMode: .fit)
        .frame(width: iconSize, height: iconSize)
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    CircularIconButton(
      icon: .systemName("chevron.left"),
      action: {}
    )
    
    CircularIconButton(
      icon: .assetName("chevron"),
      action: {}
    )
    
    CircularIconButton(
      icon: .systemName("xmark"),
      action: {},
      backgroundColor: .black.opacity(0.6),
      iconColor: .white,
      iconSize: 16
    )
    
    CircularIconButton(
      icon: .systemName("heart.fill"),
      action: {},
      backgroundColor: .red.opacity(0.1),
      iconColor: .red,
      iconSize: 18,
      padding: 14
    )
  }
  .padding()
}
