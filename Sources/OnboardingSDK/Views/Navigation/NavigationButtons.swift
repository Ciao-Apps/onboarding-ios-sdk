import SwiftUI

/// Enhanced navigation buttons with different types and positions
@available(iOS 15.0, *)
public struct NavigationButtonsView: View {
    let layout: NavigationLayoutConfig
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    public var body: some View {
        ZStack {
            // Back button
            if viewModel.canGoBack {
                NavigationButton(
                    config: layout.backButton,
                    action: { viewModel.goBack() },
                    viewModel: viewModel
                )
            }
            
            // Next/Finish button
            if viewModel.isLastPage {
                if let finishConfig = layout.finishButton {
                    NavigationButton(
                        config: finishConfig,
                        action: { viewModel.finishOnboarding() },
                        isEnabled: viewModel.canProceed,
                        viewModel: viewModel
                    )
                } else {
                    NavigationButton(
                        config: layout.nextButton,
                        action: { viewModel.finishOnboarding() },
                        isEnabled: viewModel.canProceed,
                        text: "Finish",
                        viewModel: viewModel
                    )
                }
            } else {
                NavigationButton(
                    config: layout.nextButton,
                    action: { viewModel.goForward() },
                    isEnabled: viewModel.canProceed,
                    viewModel: viewModel
                )
            }
        }
    }
}

/// Individual navigation button renderer
@available(iOS 15.0, *)
public struct NavigationButton: View {
    let config: NavigationButtonConfig
    let action: () -> Void
    let isEnabled: Bool
    let text: String?
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    public init(
        config: NavigationButtonConfig,
        action: @escaping () -> Void,
        isEnabled: Bool = true,
        text: String? = nil,
        viewModel: EnhancedOnboardingViewModel
    ) {
        self.config = config
        self.action = action
        self.isEnabled = isEnabled
        self.text = text
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Button(action: action) {
            buttonContent
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .buttonStyle(NavigationButtonStyle(config: config, viewModel: viewModel))
        .position(for: config.position)
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        switch config.type {
        case .circle:
            CircleButtonContent(config: config, viewModel: viewModel)
            
        case .pill, .rectangle, .fab:
            PillButtonContent(config: config, text: text, viewModel: viewModel)
            
        case .text:
            TextButtonContent(config: config, text: text, viewModel: viewModel)
            
        case .invisible:
            EmptyView()
        }
    }
}

// MARK: - Button Content Types

@available(iOS 15.0, *)
struct CircleButtonContent: View {
    let config: NavigationButtonConfig
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        if let icon = config.icon {
            Image(systemName: icon)
                .font(.system(size: (config.size ?? 44) * 0.4))
                .foregroundColor(viewModel.templatePrimaryColor)
        }
    }
}

@available(iOS 15.0, *)
struct PillButtonContent: View {
    let config: NavigationButtonConfig
    let text: String?
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            if let text = text ?? config.text {
                Text(text)
                    .font(.headline)
                    .foregroundColor(viewModel.primaryButtonTextColor)
            }
            
            if let icon = config.icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.primaryButtonTextColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

@available(iOS 15.0, *)
struct TextButtonContent: View {
    let config: NavigationButtonConfig
    let text: String?
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        if let text = text ?? config.text {
            Text(text)
                .font(.system(size: config.size ?? 16))
                .foregroundColor(viewModel.templateSecondaryColor)
        }
    }
}
