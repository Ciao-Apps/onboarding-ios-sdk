import SwiftUI

/// Full-width template with edge-to-edge images and bold layouts
@available(iOS 15.0, *)
struct FullWidthTemplate: View {
    let page: OnboardingPage
    @Binding var userInputs: [String: Any]
    let onInputChange: (String, Any) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Full-width image at top (if exists)
            if page.imageURL != nil {
                ImageElement.fullWidth(page)
                    .frame(maxWidth: .infinity)
            }
            
            // Content section
            VStack(spacing: 24) {
                TextElement(
                    page: page,
                    style: .bold,
                    alignment: .center
                )
                
                if page.type != .textImage {
                    InteractiveElement(
                        page: page,
                        userInputs: $userInputs,
                        onInputChange: onInputChange,
                        style: .fullWidth
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
            .background(backgroundColor)
        }
    }
    
    private var backgroundColor: Color {
        if let bgColor = page.style?.backgroundColor {
            return Color(hex: bgColor) ?? Color(.systemBackground)
        }
        return Color(.systemBackground)
    }
}
