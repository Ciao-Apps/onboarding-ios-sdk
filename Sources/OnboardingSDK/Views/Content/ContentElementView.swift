import SwiftUI

/// Pure content elements that can be used in any layout template
@available(iOS 15.0, *)
struct ContentElementView: View {
    let page: OnboardingPage
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        switch page.type {
        case .textImage:
            TextContentView(page: page)
            
        case .input:
            InputContentView(
                page: page,
                value: inputBinding
            )
            
        case .selector:
            SelectorContentView(
                page: page,
                selectedValue: selectorBinding
            )
            
        case .slider:
            SliderContentView(
                page: page,
                value: sliderBinding
            )
            
        case .template:
            TextContentView(page: page) // Fallback
        }
    }
    
    // MARK: - Bindings
    private var inputBinding: Binding<String> {
        Binding(
            get: { viewModel.userInputs[page.key ?? ""] as? String ?? "" },
            set: { viewModel.updateUserInput(key: page.key ?? "", value: $0) }
        )
    }
    
    private var selectorBinding: Binding<String> {
        Binding(
            get: { viewModel.userInputs[page.key ?? ""] as? String ?? page.options?.first ?? "" },
            set: { viewModel.updateUserInput(key: page.key ?? "", value: $0) }
        )
    }
    
    private var sliderBinding: Binding<Double> {
        Binding(
            get: { viewModel.userInputs[page.key ?? ""] as? Double ?? page.min ?? 0 },
            set: { viewModel.updateUserInput(key: page.key ?? "", value: $0) }
        )
    }
}

// MARK: - Text Content
@available(iOS 15.0, *)
struct TextContentView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            // Image
            if let imageURL = page.imageURL {
                CachedAsyncImage(url: URL(string: imageURL)) { image in
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
                .frame(maxHeight: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Text Content
            VStack(spacing: 12) {
                Text(page.title)
                    .font(titleFont)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(titleColor)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(subtitleColor)
                }
            }
        }
    }
    
    private var titleFont: Font {
        if let size = page.style?.titleFontSize {
            return .system(size: size, weight: .bold)
        }
        return .title
    }
    
    private var titleColor: Color {
        Color(hex: page.style?.titleColor) ?? .primary
    }
    
    private var subtitleColor: Color {
        Color(hex: page.style?.subtitleColor) ?? .secondary
    }
}

// MARK: - Input Content
@available(iOS 15.0, *)
struct InputContentView: View {
    let page: OnboardingPage
    @Binding var value: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Title & Subtitle
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
            
            // Input Field
            TextField(page.placeholder ?? "", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.title3)
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

// MARK: - Selector Content
@available(iOS 15.0, *)
struct SelectorContentView: View {
    let page: OnboardingPage
    @Binding var selectedValue: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Title & Subtitle
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
            
            // Options
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

// MARK: - Slider Content
@available(iOS 15.0, *)
struct SliderContentView: View {
    let page: OnboardingPage
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 24) {
            // Title & Subtitle
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
            
            // Slider
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
