import SwiftUI

/// Full-screen immersive layout template with overlay navigation
@available(iOS 15.0, *)
struct FullScreenLayoutTemplate: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let content: AnyView
    
    init(viewModel: OnboardingViewModel, @ViewBuilder content: () -> some View) {
        self.viewModel = viewModel
        self.content = AnyView(content())
    }
    
    var body: some View {
        ZStack {
            // Full-screen background
            viewModel.currentPageBackgroundColor
                .ignoresSafeArea(.all)
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageBackgroundColor)
            
            // Content overlay
            VStack(spacing: 0) {
                // Top overlay with progress
                HStack {
                    // Close/Skip button
                    Button("Skip") {
                        viewModel.finishOnboarding()
                    }
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<max(1, viewModel.flow.pages.count), id: \.self) { index in
                            Circle()
                                .fill(index <= viewModel.currentPageIndex ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)
                        }
                    }
                    
                    Spacer()
                    
                    // Page counter
                    Text("\(viewModel.currentPageIndex + 1) / \(viewModel.flow.pages.count)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Main content area
                ScrollView {
                    VStack {
                        Spacer()
                            .frame(height: 60)
                        
                        content
                            .foregroundColor(.white)
                        
                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Bottom overlay navigation
                VStack(spacing: 16) {
                    // Gesture indicator
                    if !viewModel.isLastPage {
                        HStack(spacing: 8) {
                            Text("Swipe up or tap to continue")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Image(systemName: "arrow.up")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    // Navigation buttons
                    HStack {
                        // Back button
                        if viewModel.canGoBack {
                            Button(action: viewModel.goBack) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .backdrop(Material.thin)
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        // Main action button
                        Button(action: {
                            if viewModel.isLastPage {
                                viewModel.finishOnboarding()
                            } else {
                                viewModel.goForward()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Text(viewModel.isLastPage ? "Get Started" : "Continue")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if !viewModel.isLastPage {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
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
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.y < -50 && viewModel.canGoForward {
                        viewModel.goForward()
                    } else if value.translation.y > 50 && viewModel.canGoBack {
                        viewModel.goBack()
                    }
                }
        )
    }
}


