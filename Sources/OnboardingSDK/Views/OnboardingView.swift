import SwiftUI

@available(iOS 15.0, *)
public struct OnboardingView: View {
    let flow: OnboardingFlow
    let onCompletion: ([String: Any]) -> Void
    
    @StateObject private var sdk = OnboardingSDK.shared
    @State private var currentPageIndex = 0
    @State private var userInputs: [String: Any] = [:]
    
    public init(flow: OnboardingFlow, onCompletion: @escaping ([String: Any]) -> Void) {
        self.flow = flow
        self.onCompletion = onCompletion
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressView(value: Double(currentPageIndex + 1), total: Double(flow.pages.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
                .padding(.top)
            
            // Current page content
            ScrollView {
                VStack(spacing: 24) {
                    renderCurrentPage()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            
            // Navigation buttons
            HStack {
                if currentPageIndex > 0 {
                    Button("Back") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPageIndex -= 1
                        }
                    }
                    .buttonStyle(OnboardingSecondaryButtonStyle())
                }
                
                Spacer()
                
                Button(isLastPage ? "Get Started" : "Next") {
                    if isLastPage {
                        finishOnboarding()
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPageIndex += 1
                        }
                    }
                }
                .buttonStyle(OnboardingPrimaryButtonStyle())
                .disabled(!canProceed)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private func renderCurrentPage() -> some View {
        let page = flow.pages[currentPageIndex]
        
        VStack(spacing: 24) {
            switch page.type {
            case .textImage:
                TextImagePageView(page: page)
                
            case .input:
                InputPageView(
                    page: page,
                    value: Binding(
                        get: { userInputs[page.key ?? ""] as? String ?? "" },
                        set: { newValue in
                            if let key = page.key {
                                userInputs[key] = newValue
                                sdk.updateUserInput(key: key, value: newValue, pageID: page.id)
                            }
                        }
                    )
                )
                
            case .selector:
                SelectorPageView(
                    page: page,
                    selectedValue: Binding(
                        get: { userInputs[page.key ?? ""] as? String ?? page.options?.first ?? "" },
                        set: { newValue in
                            if let key = page.key {
                                userInputs[key] = newValue
                                sdk.updateUserInput(key: key, value: newValue, pageID: page.id)
                            }
                        }
                    )
                )
                
            case .slider:
                SliderPageView(
                    page: page,
                    value: Binding(
                        get: { userInputs[page.key ?? ""] as? Double ?? page.min ?? 0 },
                        set: { newValue in
                            if let key = page.key {
                                userInputs[key] = newValue
                                sdk.updateUserInput(key: key, value: newValue, pageID: page.id)
                            }
                        }
                    )
                )
            }
        }
    }
    
    private var isLastPage: Bool {
        currentPageIndex == flow.pages.count - 1
    }
    
    private var canProceed: Bool {
        let page = flow.pages[currentPageIndex]
        
        // Check if required input is filled
        if let key = page.key, page.type != .textImage {
            return userInputs[key] != nil
        }
        
        return true
    }
    
    private func finishOnboarding() {
        sdk.finishOnboarding { finalInputs in
            onCompletion(finalInputs.isEmpty ? userInputs : finalInputs)
        }
    }
}

// MARK: - Page Components

@available(iOS 15.0, *)
struct TextImagePageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            if let imageURL = page.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                        )
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: page.style?.titleColor) ?? .primary)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: page.style?.subtitleColor) ?? .secondary)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct InputPageView: View {
    let page: OnboardingPage
    @Binding var value: String
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            
            TextField(page.placeholder ?? "", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardTypeForInput(page.inputType))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.title3)
                .padding(.vertical, 4)
        }
    }
    
    private func keyboardTypeForInput(_ inputType: InputType?) -> UIKeyboardType {
        switch inputType {
        case .number:
            return .numberPad
        case .email:
            return .emailAddress
        default:
            return .default
        }
    }
}

@available(iOS 15.0, *)
struct SelectorPageView: View {
    let page: OnboardingPage
    @Binding var selectedValue: String
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(page.options ?? [], id: \.self) { option in
                    Button(action: {
                        selectedValue = option
                    }) {
                        HStack {
                            Text(option)
                                .font(.body)
                                .foregroundColor(selectedValue == option ? .white : .primary)
                            Spacer()
                            if selectedValue == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedValue == option ? Color.blue : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct SliderPageView: View {
    let page: OnboardingPage
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 16) {
                Text("\(Int(value))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Slider(
                    value: $value,
                    in: (page.min ?? 0)...(page.max ?? 100),
                    step: page.step ?? 1
                ) {
                    Text(page.title)
                } minimumValueLabel: {
                    Text("\(Int(page.min ?? 0))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("\(Int(page.max ?? 100))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accentColor(.blue)
            }
        }
    }
}

// MARK: - Button Styles

@available(iOS 15.0, *)
struct OnboardingPrimaryButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: SwiftUI.ButtonStyle.Configuration) -> some View {
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
struct OnboardingSecondaryButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: SwiftUI.ButtonStyle.Configuration) -> some View {
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

// MARK: - Extensions

@available(iOS 15.0, *)
extension Color {
    init?(hex: String?) {
        guard let hex = hex else { return nil }
        let cleanHex = hex.replacingOccurrences(of: "#", with: "")
        
        guard cleanHex.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)
        
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
