import SwiftUI

/// Modern layout template with floating navigation and smooth animations
@available(iOS 15.0, *)
struct ModernLayoutTemplate: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let content: AnyView
    
    init(viewModel: OnboardingViewModel, @ViewBuilder content: () -> some View) {
        self.viewModel = viewModel
        self.content = AnyView(content())
    }
    
    var body: some View {
        ZStack {
            // Background
            viewModel.currentPageBackgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageBackgroundColor)
            
            VStack(spacing: 0) {
                // Modern Progress Indicator
                HStack {
                    ForEach(0..<max(1, viewModel.flow.pages.count), id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index <= viewModel.currentPageIndex ? Color.white : Color.white.opacity(0.3))
                            .frame(height: 4)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Content with floating card effect
                ScrollView {
                    VStack(spacing: 24) {
                        content
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 120) // Space for floating navigation
                }
                
                Spacer()
            }
            
            // Floating Navigation
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    // Back Button
                    if viewModel.canGoBack {
                        Button(action: viewModel.goBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    // Next/Finish Button
                    Button(action: {
                        if viewModel.isLastPage {
                            viewModel.finishOnboarding()
                        } else {
                            viewModel.goForward()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(viewModel.isLastPage ? "Get Started" : "Next")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if !viewModel.isLastPage {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                    }
                    .disabled(!viewModel.canProceed)
                    .opacity(viewModel.canProceed ? 1.0 : 0.6)
                    .scaleEffect(viewModel.canProceed ? 1.0 : 0.95)
                    .animation(.spring(response: 0.3), value: viewModel.canProceed)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }
}


