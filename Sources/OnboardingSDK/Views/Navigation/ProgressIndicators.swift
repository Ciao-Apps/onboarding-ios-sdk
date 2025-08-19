import SwiftUI

/// Enhanced progress indicator that supports different types and animations
@available(iOS 15.0, *)
public struct ProgressIndicatorView: View {
    let config: ProgressIndicatorConfig
    let progress: Double
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    public var body: some View {
        switch config.type {
        case .line:
            LineProgressIndicator(config: config, progress: progress, viewModel: viewModel)
            
        case .dots:
            DotProgressIndicator(config: config, viewModel: viewModel)
            
        case .bubbles:
            BubbleProgressIndicator(config: config, viewModel: viewModel)
            
        case .stepCounter:
            StepCounterIndicator(config: config, viewModel: viewModel)
            
        case .gradient:
            GradientProgressIndicator(config: config, progress: progress, viewModel: viewModel)
            
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Individual Progress Types

@available(iOS 15.0, *)
struct LineProgressIndicator: View {
    let config: ProgressIndicatorConfig
    let progress: Double
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        ProgressView(value: progress)
            .progressViewStyle(LinearProgressViewStyle(tint: viewModel.templatePrimaryColor))
            .frame(height: config.height ?? 3)
            .padding(.horizontal, 20)
    }
}

@available(iOS 15.0, *)
struct DotProgressIndicator: View {
    let config: ProgressIndicatorConfig
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        HStack(spacing: config.spacing ?? 8) {
            ForEach(0..<viewModel.flow.pages.count, id: \.self) { index in
                Circle()
                    .fill(index <= viewModel.currentPageIndex ? viewModel.templatePrimaryColor : viewModel.templateSecondaryColor.opacity(0.3))
                    .frame(width: config.size ?? 8, height: config.size ?? 8)
                    .scaleEffect(index == viewModel.currentPageIndex ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)
            }
        }
        .padding(.horizontal, 20)
    }
}

@available(iOS 15.0, *)
struct BubbleProgressIndicator: View {
    let config: ProgressIndicatorConfig
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        HStack(spacing: config.spacing ?? 8) {
            ForEach(0..<viewModel.flow.pages.count, id: \.self) { index in
                Circle()
                    .fill(index <= viewModel.currentPageIndex ? viewModel.templatePrimaryColor : viewModel.templateSecondaryColor.opacity(0.2))
                    .frame(width: config.size ?? 12, height: config.size ?? 12)
                    .scaleEffect(index == viewModel.currentPageIndex ? 1.3 : 1.0)
                    .offset(y: index == viewModel.currentPageIndex ? -2 : 0)
                    .animation(.bouncy, value: viewModel.currentPageIndex)
            }
        }
        .padding(.horizontal, 20)
    }
}

@available(iOS 15.0, *)
struct StepCounterIndicator: View {
    let config: ProgressIndicatorConfig
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        Text("\(viewModel.currentPageIndex + 1) of \(viewModel.flow.pages.count)")
            .font(.caption)
            .foregroundColor(viewModel.templateSecondaryColor)
            .padding(.horizontal, 20)
    }
}

@available(iOS 15.0, *)
struct GradientProgressIndicator: View {
    let config: ProgressIndicatorConfig
    let progress: Double
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(viewModel.templateSecondaryColor.opacity(0.2))
                    .frame(height: config.height ?? 4)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [viewModel.templatePrimaryColor, viewModel.templateSecondaryColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: config.height ?? 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: config.height ?? 4)
        .padding(.horizontal, 20)
    }
}
