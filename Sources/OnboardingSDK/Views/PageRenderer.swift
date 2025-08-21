import SwiftUI

/// Simple page renderer for Craft.js-based onboarding
@available(iOS 15.0, *)
public struct PageRenderer: View {
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    public var body: some View {
        // Simple TabView with Craft.js content handling all navigation
        TabView(selection: $viewModel.currentPageIndex) {
            ForEach(Array(viewModel.flow.pages.enumerated()), id: \.element.id) { index, page in
                PageView(page: page, viewModel: viewModel)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .disabled(viewModel.isNavigating)
    }
}
