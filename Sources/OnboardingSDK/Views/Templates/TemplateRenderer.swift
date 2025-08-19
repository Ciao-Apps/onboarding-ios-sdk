import SwiftUI

/// Central template renderer that chooses the right layout based on page style
@available(iOS 15.0, *)
struct TemplateRenderer: View {
    let page: OnboardingPage
    @Binding var userInputs: [String: Any]
    let onInputChange: (String, Any) -> Void
    
    var body: some View {
        Group {
            // Check if a specific template is requested
            if let templateName = page.style?.template {
                renderTemplate(templateName)
            } else {
                // Fall back to default layouts based on type
                renderDefaultLayout()
            }
        }
    }
    
    @ViewBuilder
    private func renderTemplate(_ templateName: String) -> some View {
        switch templateName.lowercased() {
        case "hero":
            HeroTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case "card":
            CardTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case "split":
            SplitTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case "minimal":
            MinimalTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case "fullwidth":
            FullWidthTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case "creative_slider":
            CreativeSliderTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        default:
            // Unknown template, fall back to default
            renderDefaultLayout()
        }
    }
    
    @ViewBuilder
    private func renderDefaultLayout() -> some View {
        switch page.type {
        case .textImage:
            CardTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case .input:
            MinimalTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case .selector:
            CardTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case .slider:
            SplitTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        case .template:
            CardTemplate(page: page, userInputs: $userInputs, onInputChange: onInputChange)
        }
    }
}
