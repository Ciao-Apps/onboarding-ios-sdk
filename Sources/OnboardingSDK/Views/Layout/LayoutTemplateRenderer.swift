import SwiftUI

/// Renders the appropriate layout template based on the selected template
@available(iOS 15.0, *)
struct LayoutTemplateRenderer: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        Group {
            switch viewModel.selectedTemplate {
            case .classic:
                ClassicLayoutTemplate(viewModel: viewModel) {
                    contentView
                }
                
            case .modern:
                ModernLayoutTemplate(viewModel: viewModel) {
                    contentView
                }
                
            case .fullScreen:
                FullScreenLayoutTemplate(viewModel: viewModel) {
                    contentView
                }
                
            case .minimal:
                MinimalLayoutTemplate(viewModel: viewModel) {
                    contentView
                }
                
            case .cardStack:
                CardStackLayoutTemplate(viewModel: viewModel) {
                    contentView
                }
                
            default:
                // Fallback to classic for any unimplemented templates
                ClassicLayoutTemplate(viewModel: viewModel) {
                    contentView
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let page = viewModel.currentPage {
            ContentElementView(page: page, viewModel: viewModel)
        } else {
            // Fallback for invalid page
            VStack {
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Additional Layout Templates (Simplified versions)

@available(iOS 15.0, *)
struct MinimalLayoutTemplate: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let content: AnyView
    
    init(viewModel: OnboardingViewModel, @ViewBuilder content: () -> some View) {
        self.viewModel = viewModel
        self.content = AnyView(content())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Minimal progress
            HStack {
                Text("\(viewModel.currentPageIndex + 1) of \(viewModel.flow.pages.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // Content
            ScrollView {
                VStack(spacing: 40) {
                    content
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 60)
            }
            
            // Minimal navigation
            HStack {
                if viewModel.canGoBack {
                    Button("Back") {
                        viewModel.goBack()
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(viewModel.isLastPage ? "Finish" : "Next") {
                    if viewModel.isLastPage {
                        viewModel.finishOnboarding()
                    } else {
                        viewModel.goForward()
                    }
                }
                .font(.headline)
                .foregroundColor(.blue)
                .disabled(!viewModel.canProceed)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .background(viewModel.currentPageBackgroundColor)
    }
}

@available(iOS 15.0, *)
struct CardStackLayoutTemplate: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let content: AnyView
    
    init(viewModel: OnboardingViewModel, @ViewBuilder content: () -> some View) {
        self.viewModel = viewModel
        self.content = AnyView(content())
    }
    
    var body: some View {
        ZStack {
            viewModel.currentPageBackgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Progress
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Card stack effect
                ZStack {
                    // Background cards (for stack effect)
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .offset(y: CGFloat(index) * 8)
                            .scaleEffect(1.0 - CGFloat(index) * 0.05)
                    }
                    
                    // Main content card
                    VStack(spacing: 24) {
                        content
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                }
                .padding(.horizontal, 20)
                
                // Navigation
                HStack(spacing: 16) {
                    if viewModel.canGoBack {
                        Button(action: viewModel.goBack) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.isLastPage {
                            viewModel.finishOnboarding()
                        } else {
                            viewModel.goForward()
                        }
                    }) {
                        Text(viewModel.isLastPage ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(viewModel.currentPageBackgroundColor)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(Color.white))
                    }
                    .disabled(!viewModel.canProceed)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }
}


