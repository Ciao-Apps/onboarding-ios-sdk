import SwiftUI

/// Reusable text component with flexible styling
@available(iOS 15.0, *)
struct TextElement: View {
    let page: OnboardingPage
    let style: TextStyle
    let alignment: TextElementAlignment
    
    enum TextStyle {
        case standard       // Regular page text
        case bold          // Emphasized text
        case heroOverlay   // Hero template text
        case minimal       // Subtle text
        case card          // Card template text
    }
    
    enum TextElementAlignment {
        case leading, center, trailing
    }
    
    enum FontWeight {
        case regular, medium, semibold, bold
        
        var swiftUIWeight: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }
    
    var body: some View {
        VStack(spacing: textSpacing) {
            Text(page.title)
                .font(titleFont)
                .fontWeight(titleWeight.swiftUIWeight)
                .multilineTextAlignment(swiftUIAlignment)
                .foregroundColor(titleColor)
            
            if let subtitle = page.subtitle {
                Text(subtitle)
                    .font(subtitleFont)
                    .fontWeight(subtitleWeight.swiftUIWeight)
                    .multilineTextAlignment(swiftUIAlignment)
                    .foregroundColor(subtitleColor)
            }
        }
    }
    
    // MARK: - Style Calculations
    
    private var titleFont: Font {
        if let size = page.style?.titleFontSize {
            return .system(size: size, weight: titleWeight.swiftUIWeight)
        }
        
        switch style {
        case .standard: return .title2
        case .bold: return .largeTitle
        case .heroOverlay: return .system(size: 34, weight: .bold)
        case .minimal: return .title3
        case .card: return .title2
        }
    }
    
    private var subtitleFont: Font {
        if let size = page.style?.subtitleFontSize {
            return .system(size: size, weight: subtitleWeight.swiftUIWeight)
        }
        
        switch style {
        case .standard: return .body
        case .bold: return .title3
        case .heroOverlay: return .system(size: 18, weight: .medium)
        case .minimal: return .callout
        case .card: return .body
        }
    }
    
    private var titleWeight: FontWeight {
        switch style {
        case .standard: return .semibold
        case .bold: return .bold
        case .heroOverlay: return .bold
        case .minimal: return .medium
        case .card: return .semibold
        }
    }
    
    private var subtitleWeight: FontWeight {
        switch style {
        case .heroOverlay: return .medium
        default: return .regular
        }
    }
    
    private var titleColor: Color {
        if let colorHex = page.style?.titleColor {
            return Color(hex: colorHex) ?? defaultTitleColor
        }
        return defaultTitleColor
    }
    
    private var subtitleColor: Color {
        if let colorHex = page.style?.subtitleColor {
            return Color(hex: colorHex) ?? defaultSubtitleColor
        }
        return defaultSubtitleColor
    }
    
    private var defaultTitleColor: Color {
        switch style {
        case .heroOverlay: return .white
        default: return .primary
        }
    }
    
    private var defaultSubtitleColor: Color {
        switch style {
        case .heroOverlay: return .white.opacity(0.9)
        default: return .secondary
        }
    }
    
    private var textSpacing: CGFloat {
        page.style?.spacing ?? 12
    }
    
    private var swiftUIAlignment: TextAlignment {
        switch alignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}
