import SwiftUI

/// Hero template with background image and overlay content
@available(iOS 15.0, *)
struct HeroTemplate: View {
    let page: OnboardingPage
    @Binding var userInputs: [String: Any]
    let onInputChange: (String, Any) -> Void
    
    var body: some View {
        ZStack {
            // Background image
            if page.imageURL != nil {
                ImageElement.hero(page)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Gradient overlay for text readability
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                // Fallback gradient background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // Content overlay
            VStack(spacing: 32) {
                Spacer()
                
                TextElement(
                    page: page,
                    style: .heroOverlay,
                    alignment: .center
                )
                
                if page.type != .textImage {
                    InteractiveElement(
                        page: page,
                        userInputs: $userInputs,
                        onInputChange: onInputChange,
                        style: .overlay
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }
}
