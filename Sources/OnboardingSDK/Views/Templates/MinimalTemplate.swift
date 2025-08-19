import SwiftUI

/// Minimal template focused on content without distractions
@available(iOS 15.0, *)
struct MinimalTemplate: View {
    let page: OnboardingPage
    @Binding var userInputs: [String: Any]
    let onInputChange: (String, Any) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Small image (if any)
            if page.imageURL != nil {
                ImageElement.minimal(page)
                    .frame(maxWidth: 200)
            }
            
            // Text content
            TextElement(
                page: page,
                style: .minimal,
                alignment: .center
            )
            
            // Interactive element
            if page.type != .textImage {
                InteractiveElement(
                    page: page,
                    userInputs: $userInputs,
                    onInputChange: onInputChange,
                    style: .minimal
                )
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .background(backgroundColor)
    }
    
    private var backgroundColor: Color {
        if let bgColor = page.style?.backgroundColor {
            return Color(hex: bgColor) ?? Color(.systemBackground)
        }
        return Color(.systemBackground)
    }
}
