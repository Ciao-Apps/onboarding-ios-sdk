import SwiftUI

/// Smart image component with flexible styling options
@available(iOS 15.0, *)
struct ImageElement: View {
    let page: OnboardingPage
    let style: ImageDisplayStyle
    
    enum ImageDisplayStyle {
        case card           // Rounded corners, contained
        case fullWidth      // Edge-to-edge, no borders
        case hero           // Background cover style
        case floating       // Centered with shadow
        case minimal        // Simple, no decoration
    }
    
    var body: some View {
        Group {
            if let imageURL = page.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: imageContentMode)
                } placeholder: {
                    placeholderView
                }
                .frame(width: imageWidth, height: imageHeight)
                .clipped()
                .modifier(imageStyleModifier)
            }
        }
    }
    
    // MARK: - Style Calculations
    
    private var imageContentMode: ContentMode {
        switch style {
        case .hero: return .fill
        case .fullWidth: return .fill
        default: return .fit
        }
    }
    
    private var imageWidth: CGFloat? {
        switch style {
        case .fullWidth, .hero: return nil  // Full width
        default: return page.style?.imageSize?.width.map(CGFloat.init)
        }
    }
    
    private var imageHeight: CGFloat? {
        let styleHeight = page.style?.imageSize?.height.map(CGFloat.init)
        switch style {
        case .card: return styleHeight ?? 200
        case .fullWidth: return styleHeight ?? 250
        case .hero: return styleHeight ?? 300
        case .floating: return styleHeight ?? 180
        case .minimal: return styleHeight ?? 120
        }
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Image(systemName: placeholderIcon)
                    .foregroundColor(.gray)
                    .font(.system(size: placeholderIconSize))
            )
    }
    
    private var placeholderIcon: String {
        switch style {
        case .hero: return "photo.fill"
        case .minimal: return "photo"
        default: return "photo"
        }
    }
    
    private var placeholderIconSize: CGFloat {
        switch style {
        case .hero: return 60
        case .minimal: return 30
        default: return 40
        }
    }
    
    @ViewBuilder
    private var imageStyleModifier: some View {
        switch style {
        case .card:
            RoundedRectangle(cornerRadius: 12)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
        case .fullWidth:
            Rectangle()  // No borders, no corners
                
        case .hero:
            Rectangle()  // Full background
                
        case .floating:
            RoundedRectangle(cornerRadius: 16)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
        case .minimal:
            RoundedRectangle(cornerRadius: 8)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Convenience Initializers
@available(iOS 15.0, *)
extension ImageElement {
    static func card(_ page: OnboardingPage) -> ImageElement {
        ImageElement(page: page, style: .card)
    }
    
    static func fullWidth(_ page: OnboardingPage) -> ImageElement {
        ImageElement(page: page, style: .fullWidth)
    }
    
    static func hero(_ page: OnboardingPage) -> ImageElement {
        ImageElement(page: page, style: .hero)
    }
    
    static func floating(_ page: OnboardingPage) -> ImageElement {
        ImageElement(page: page, style: .floating)
    }
    
    static func minimal(_ page: OnboardingPage) -> ImageElement {
        ImageElement(page: page, style: .minimal)
    }
}
