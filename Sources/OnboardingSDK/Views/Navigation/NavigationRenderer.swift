import SwiftUI

/// Enhanced navigation renderer using NavigationLayoutConfig
@available(iOS 15.0, *)
public struct NavigationRenderer: View {
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    private var navigationLayout: NavigationLayoutConfig? {
        viewModel.template.navigationLayout
    }
    
    public var body: some View {
        ZStack {
            // Main content area
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top progress indicator
                    if let layout = navigationLayout,
                       layout.progressIndicator.position == .top || layout.progressIndicator.position == .topSafe {
                        ProgressIndicatorView(
                            config: layout.progressIndicator,
                            progress: viewModel.progress,
                            viewModel: viewModel
                        )
                        .padding(.top, layout.progressIndicator.position == .topSafe ? 20 : 0)
                    }
                    
                    // Main content with padding from navigation layout
                    TabView(selection: $viewModel.currentPageIndex) {
                        ForEach(Array(viewModel.flow.pages.enumerated()), id: \.element.id) { index, page in
                            PageView(page: page, viewModel: viewModel)
                                .padding(.top, navigationLayout?.contentPadding?.top ?? 0)
                                .padding(.bottom, navigationLayout?.contentPadding?.bottom ?? 0)
                                .padding(.leading, navigationLayout?.contentPadding?.leading ?? 0)
                                .padding(.trailing, navigationLayout?.contentPadding?.trailing ?? 0)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .disabled(viewModel.isNavigating)
                    
                    Spacer()
                    
                    // Bottom progress indicator
                    if let layout = navigationLayout,
                       layout.progressIndicator.position == .bottom || layout.progressIndicator.position == .bottomSafe {
                        ProgressIndicatorView(
                            config: layout.progressIndicator,
                            progress: viewModel.progress,
                            viewModel: viewModel
                        )
                        .padding(.bottom, layout.progressIndicator.position == .bottomSafe ? 20 : 0)
                    }
                }
            }
            
            // Navigation buttons overlay
            if let layout = navigationLayout {
                NavigationButtonsView(layout: layout, viewModel: viewModel)
            }
        }
    }
}
