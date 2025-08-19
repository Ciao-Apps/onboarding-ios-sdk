import SwiftUI

/// Classic layout template with traditional bottom navigation
@available(iOS 15.0, *)
struct ClassicLayoutTemplate: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let content: AnyView
    
    init(viewModel: OnboardingViewModel, @ViewBuilder content: () -> some View) {
        self.viewModel = viewModel
        self.content = AnyView(content())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
                .padding(.top)
            
            // Content Area
            ScrollView {
                VStack(spacing: 24) {
                    content
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            
            // Bottom Navigation
            HStack(spacing: 16) {
                // Back Button
                if viewModel.canGoBack {
                    Button("Back") {
                        viewModel.goBack()
                    }
                    .buttonStyle(ClassicSecondaryButtonStyle())
                } else {
                    // Invisible spacer to maintain layout
                    Button("") { }
                        .buttonStyle(ClassicSecondaryButtonStyle())
                        .opacity(0)
                        .disabled(true)
                }
                
                Spacer()
                
                // Next/Finish Button
                Button(viewModel.isLastPage ? "Get Started" : "Next") {
                    if viewModel.isLastPage {
                        viewModel.finishOnboarding()
                    } else {
                        viewModel.goForward()
                    }
                }
                .buttonStyle(ClassicPrimaryButtonStyle())
                .disabled(!viewModel.canProceed)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
            .background(Color(.systemBackground))
        }
        .background(viewModel.currentPageBackgroundColor)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageBackgroundColor)
    }
}

// MARK: - Classic Button Styles
@available(iOS 15.0, *)
struct ClassicPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

@available(iOS 15.0, *)
struct ClassicSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .frame(height: 52)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.blue, lineWidth: 2)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}
