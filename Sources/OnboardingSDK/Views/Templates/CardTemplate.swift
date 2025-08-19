import SwiftUI

/// Clean card-based template with contained content
@available(iOS 15.0, *)
struct CardTemplate: View {
    let page: OnboardingPage
    @Binding var userInputs: [String: Any]
    let onInputChange: (String, Any) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Card image
            if page.imageURL != nil {
                ImageElement.card(page)
            }
            
            // Text content
            TextElement(
                page: page,
                style: .standard,
                alignment: .center
            )
            
            // Interactive element
            if page.type != .textImage {
                InteractiveElement(
                    page: page,
                    userInputs: $userInputs,
                    onInputChange: onInputChange,
                    style: .card
                )
            }
        }
        .padding(contentPadding)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var backgroundColor: Color {
        if let bgColor = page.style?.backgroundColor {
            return Color(hex: bgColor) ?? Color(.systemBackground)
        }
        return Color(.systemBackground)
    }
    
    private var contentPadding: EdgeInsets {
        let style = page.style
        return EdgeInsets(
            top: style?.padding?.top ?? 24,
            leading: style?.padding?.leading ?? 20,
            bottom: style?.padding?.bottom ?? 24,
            trailing: style?.padding?.trailing ?? 20
        )
    }
}
