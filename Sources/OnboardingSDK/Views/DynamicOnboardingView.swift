import SwiftUI

/// A lean, drop-in onboarding view that fetches flows from the SDK
/// Just add this to your existing app structure - no changes needed
@available(iOS 15.0, *)
public struct DynamicOnboardingView: View {
    let appID: String
    let flowID: String
    let templateID: String?
    let onCompletion: ([String: Any]) -> Void
    
    @State private var viewModel: EnhancedOnboardingViewModel?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    /// Simple drop-in onboarding view
    /// - Parameters:
    ///   - appID: Your app identifier
    ///   - flowID: The onboarding flow to load
    ///   - templateID: Optional template to apply (modern, minimal, vibrant, corporate, playful)
    ///   - onCompletion: Called when user completes onboarding with their input data
    public init(
        appID: String,
        flowID: String,
        templateID: String? = nil,
        onCompletion: @escaping ([String: Any]) -> Void
    ) {
        self.appID = appID
        self.flowID = flowID
        self.templateID = templateID
        self.onCompletion = onCompletion
    }
    
    public var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if let errorMessage = errorMessage {
                ErrorView(message: errorMessage) {
                    loadOnboardingFlow()
                }
            } else if let viewModel = viewModel {
                OnboardingView(viewModel: viewModel)
            } else {
                ErrorView(message: "Onboarding flow not available") {
                    loadOnboardingFlow()
                }
            }
        }
        .onAppear {
            loadOnboardingFlow()
        }
    }
    
    private func loadOnboardingFlow() {
        isLoading = true
        errorMessage = nil
        
        // Configure SDK
        OnboardingSDK.shared.configure(appID: appID)
        
        // Create ViewModel using enhanced system
        if let vm = OnboardingSDK.shared.createViewModel(
            flowID: flowID,
            templateID: templateID,
            onCompletion: onCompletion
        ) {
            self.viewModel = vm
            self.isLoading = false
            print("DynamicOnboardingView: ✅ Loaded enhanced flow with template: \(templateID ?? "default")")
        } else {
            self.errorMessage = "Failed to load onboarding flow"
            self.isLoading = false
            print("DynamicOnboardingView: ❌ Failed to load flow: \(flowID)")
        }
    }
}

/// Clean onboarding view using the enhanced template system
@available(iOS 15.0, *)
struct OnboardingView: View {
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        ZStack {
            // Background with animation
            viewModel.currentPageBackgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)
            
            if viewModel.isLoading {
                ProgressView("Finishing up...")
                    .foregroundColor(viewModel.templateTextColor)
            } else {
                VStack(spacing: 0) {
                    // Progress indicator (except for immersive)
                    if viewModel.navigationStyle != .immersive {
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: viewModel.templatePrimaryColor))
                            .padding(.horizontal, viewModel.mediumSpacing)
                            .padding(.top, viewModel.smallSpacing)
                    }
                    
                    // Main content
                    TabView(selection: $viewModel.currentPageIndex) {
                        ForEach(Array(viewModel.flow.pages.enumerated()), id: \.element.id) { index, page in
                            PageView(page: page, viewModel: viewModel)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .disabled(viewModel.isNavigating)
                    
                    // Navigation
                    NavigationView(viewModel: viewModel)
                }
            }
        }
    }
}

/// Individual page renderer
@available(iOS 15.0, *)
struct PageView: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: viewModel.largeSpacing) {
                // Page content based on type
                switch page.pageType {
                case .hero:
                    HeroContent(page: page, viewModel: viewModel)
                case .content:
                    ContentPageContent(page: page, viewModel: viewModel)
                case .form:
                    FormContent(page: page, viewModel: viewModel)
                case .feature:
                    FeatureContent(page: page, viewModel: viewModel)
                case .completion:
                    CompletionContent(page: page, viewModel: viewModel)
                }
            }
            .padding(.horizontal, viewModel.mediumSpacing)
            .padding(.top, viewModel.largeSpacing)
        }
    }
}

// MARK: - Page Content Components

@available(iOS 15.0, *)
struct HeroContent: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        VStack(spacing: viewModel.extraLargeSpacing) {
            if let imageURL = page.imageURL {
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: viewModel.templateCornerRadius))
                } placeholder: {
                    RoundedRectangle(cornerRadius: viewModel.templateCornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay(ProgressView())
                }
            }
            
            VStack(spacing: viewModel.mediumSpacing) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.templateTextColor)
                    .multilineTextAlignment(.center)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.title2)
                        .foregroundColor(viewModel.templateTextColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            
            InteractiveContent(page: page, viewModel: viewModel)
        }
    }
}

@available(iOS 15.0, *)
struct ContentPageContent: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        VStack(spacing: viewModel.largeSpacing) {
            VStack(spacing: viewModel.mediumSpacing) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.templateTextColor)
                    .multilineTextAlignment(.center)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(viewModel.templateTextColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            
            if let imageURL = page.imageURL {
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: viewModel.templateCornerRadius))
                } placeholder: {
                    ProgressView()
                }
            }
            
            InteractiveContent(page: page, viewModel: viewModel)
        }
    }
}

@available(iOS 15.0, *)
struct FormContent: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        VStack(spacing: viewModel.largeSpacing) {
            VStack(spacing: viewModel.mediumSpacing) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.templateTextColor)
                    .multilineTextAlignment(.center)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(viewModel.templateTextColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
            
            InteractiveContent(page: page, viewModel: viewModel)
        }
        .padding(.top, viewModel.extraLargeSpacing)
    }
}

@available(iOS 15.0, *)
struct FeatureContent: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        VStack(spacing: viewModel.largeSpacing) {
            if let imageURL = page.imageURL {
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: viewModel.templateCornerRadius))
                } placeholder: {
                    ProgressView()
                }
            }
            
            VStack(spacing: viewModel.mediumSpacing) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.templateTextColor)
                    .multilineTextAlignment(.center)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(viewModel.templateTextColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            
            InteractiveContent(page: page, viewModel: viewModel)
        }
    }
}

@available(iOS 15.0, *)
struct CompletionContent: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        VStack(spacing: viewModel.extraLargeSpacing) {
            Spacer()
            
            if let imageURL = page.imageURL {
                CachedAsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(viewModel.templatePrimaryColor)
            }
            
            VStack(spacing: viewModel.mediumSpacing) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.templateTextColor)
                    .multilineTextAlignment(.center)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundColor(viewModel.templateTextColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Navigation

@available(iOS 15.0, *)
struct NavigationView: View {
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        HStack {
            if viewModel.canGoBack {
                Button("Back") {
                    viewModel.goBack()
                }
                .foregroundColor(viewModel.templateSecondaryColor)
            }
            
            Spacer()
            
            Button(viewModel.isLastPage ? "Finish" : "Next") {
                if viewModel.isLastPage {
                    viewModel.finishOnboarding()
                } else {
                    viewModel.goForward()
                }
            }
            .disabled(!viewModel.canProceed)
            .padding(.horizontal, viewModel.largeSpacing)
            .padding(.vertical, viewModel.mediumSpacing)
            .background(viewModel.canProceed ? viewModel.primaryButtonBackgroundColor : Color.gray)
            .foregroundColor(viewModel.primaryButtonTextColor)
            .clipShape(RoundedRectangle(cornerRadius: viewModel.buttonCornerRadius))
        }
        .padding(.horizontal, viewModel.mediumSpacing)
        .padding(.bottom, viewModel.mediumSpacing)
    }
}

// MARK: - Helper Views

@available(iOS 15.0, *)
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading onboarding...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

@available(iOS 15.0, *)
private struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(OnboardingRetryButtonStyle())
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

@available(iOS 15.0, *)
private struct OnboardingRetryButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: SwiftUI.ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 120, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

// MARK: - Interactive Content

@available(iOS 15.0, *)
struct InteractiveContent: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        switch page.contentType {
        case .textImage:
            EmptyView() // No interactive content for text/image
            
        case .input:
            InputElement(page: page, viewModel: viewModel)
            
        case .selector:
            SelectorElement(page: page, viewModel: viewModel)
            
        case .slider:
            SliderElement(page: page, viewModel: viewModel)
        }
    }
}

@available(iOS 15.0, *)
struct InputElement: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    @State private var inputValue: String = ""
    
    var body: some View {
        VStack(spacing: viewModel.mediumSpacing) {
            TextField(page.placeholder ?? "Enter text", text: $inputValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(page.inputType == .email)
                .font(.title3)
                .padding(.horizontal, viewModel.smallSpacing)
                .onChange(of: inputValue) { newValue in
                    if let key = page.key {
                        viewModel.updateUserInput(key: key, value: newValue)
                    }
                }
        }
        .onAppear {
            if let key = page.key {
                inputValue = viewModel.userInputs[key] as? String ?? ""
            }
        }
    }
    
    private var keyboardType: UIKeyboardType {
        switch page.inputType {
        case .number: return .numberPad
        case .email: return .emailAddress
        default: return .default
        }
    }
}

@available(iOS 15.0, *)
struct SelectorElement: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    @State private var selectedValue: String = ""
    
    var body: some View {
        VStack(spacing: viewModel.mediumSpacing) {
            ForEach(page.options ?? [], id: \.self) { option in
                Button(action: {
                    selectedValue = option
                    if let key = page.key {
                        viewModel.updateUserInput(key: key, value: option)
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(.body)
                            .foregroundColor(selectedValue == option ? viewModel.primaryButtonTextColor : viewModel.templateTextColor)
                        Spacer()
                        if selectedValue == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(viewModel.primaryButtonTextColor)
                        }
                    }
                    .padding(viewModel.mediumSpacing)
                    .background(
                        RoundedRectangle(cornerRadius: viewModel.templateCornerRadius)
                            .fill(selectedValue == option ? viewModel.primaryButtonBackgroundColor : Color(.systemGray6))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            if let key = page.key {
                selectedValue = viewModel.userInputs[key] as? String ?? page.options?.first ?? ""
            }
        }
    }
}

@available(iOS 15.0, *)
struct SliderElement: View {
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    @State private var sliderValue: Double = 0
    
    var body: some View {
        VStack(spacing: viewModel.largeSpacing) {
            // Value display
            Text("\(Int(sliderValue))")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(viewModel.templatePrimaryColor)
            
            // Slider
            Slider(
                value: $sliderValue,
                in: (page.min ?? 0)...(page.max ?? 100),
                step: page.step ?? 1
            ) {
                Text(page.title)
            } minimumValueLabel: {
                Text("\(Int(page.min ?? 0))")
                    .font(.caption)
                    .foregroundColor(viewModel.templateSecondaryColor)
            } maximumValueLabel: {
                Text("\(Int(page.max ?? 100))")
                    .font(.caption)
                    .foregroundColor(viewModel.templateSecondaryColor)
            }
            .accentColor(viewModel.templatePrimaryColor)
            .onChange(of: sliderValue) { newValue in
                if let key = page.key {
                    viewModel.updateUserInput(key: key, value: newValue)
                }
            }
        }
        .onAppear {
            if let key = page.key {
                sliderValue = viewModel.userInputs[key] as? Double ?? page.min ?? 0
            }
        }
    }
}