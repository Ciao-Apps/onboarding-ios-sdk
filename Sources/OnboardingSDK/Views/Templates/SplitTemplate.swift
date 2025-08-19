import SwiftUI

/// Split template with side-by-side layout
@available(iOS 15.0, *)
struct SplitTemplate: View {
    let page: OnboardingPage
    @Binding var userInputs: [String: Any]
    let onInputChange: (String, Any) -> Void
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad || UIScreen.main.bounds.width > 600 {
            // iPad or wide screen: side-by-side layout
            HStack(spacing: 32) {
                leftContent
                rightContent
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        } else {
            // iPhone: stacked layout
            VStack(spacing: 24) {
                leftContent
                rightContent
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
    
    @ViewBuilder
    private var leftContent: some View {
        VStack(spacing: 20) {
            if page.imageURL != nil {
                ImageElement.floating(page)
            }
            
            TextElement(
                page: page,
                style: .standard,
                alignment: .leading
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var rightContent: some View {
        VStack {
            if page.type != .textImage {
                InteractiveElement(
                    page: page,
                    userInputs: $userInputs,
                    onInputChange: onInputChange,
                    style: .card
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}
