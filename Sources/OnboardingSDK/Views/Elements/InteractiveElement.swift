import SwiftUI

/// Unified interactive element that renders inputs, selectors, and sliders
@available(iOS 15.0, *)
struct InteractiveElement: View {
    let page: OnboardingPage
    @Binding var userInputs: [String: Any]
    let onInputChange: (String, Any) -> Void
    let style: InteractiveStyle
    
    enum InteractiveStyle {
        case card        // Standard card styling
        case fullWidth   // Full-width styling
        case overlay     // Hero overlay styling
        case minimal     // Minimal styling
    }
    
    var body: some View {
        switch page.type {
        case .input:
            InputElement(
                page: page,
                value: inputBinding,
                style: style
            )
            
        case .selector:
            SelectorElement(
                page: page,
                selectedValue: selectorBinding,
                style: style
            )
            
        case .slider:
            SliderElement(
                page: page,
                value: sliderBinding,
                style: style
            )
            
        default:
            EmptyView()
        }
    }
    
    // MARK: - Bindings
    
    private var inputBinding: Binding<String> {
        Binding(
            get: { userInputs[page.key ?? ""] as? String ?? "" },
            set: { newValue in
                if let key = page.key {
                    userInputs[key] = newValue
                    onInputChange(key, newValue)
                }
            }
        )
    }
    
    private var selectorBinding: Binding<String> {
        Binding(
            get: { userInputs[page.key ?? ""] as? String ?? page.options?.first ?? "" },
            set: { newValue in
                if let key = page.key {
                    userInputs[key] = newValue
                    onInputChange(key, newValue)
                }
            }
        )
    }
    
    private var sliderBinding: Binding<Double> {
        Binding(
            get: { userInputs[page.key ?? ""] as? Double ?? page.min ?? 0 },
            set: { newValue in
                if let key = page.key {
                    userInputs[key] = newValue
                    onInputChange(key, newValue)
                }
            }
        )
    }
}

// MARK: - Input Element
@available(iOS 15.0, *)
struct InputElement: View {
    let page: OnboardingPage
    @Binding var value: String
    let style: InteractiveElement.InteractiveStyle
    
    var body: some View {
        Group {
            switch style {
            case .overlay:
                TextField(page.placeholder ?? "", text: $value)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(inputFont)
            default:
                TextField(page.placeholder ?? "", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(inputFont)
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
    
    private var inputFont: Font {
        switch style {
        case .overlay: return .title3
        case .minimal: return .body
        default: return .title3
        }
    }
}

// MARK: - Selector Element
@available(iOS 15.0, *)
struct SelectorElement: View {
    let page: OnboardingPage
    @Binding var selectedValue: String
    let style: InteractiveElement.InteractiveStyle
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(page.options ?? [], id: \.self) { option in
                Button(action: {
                    selectedValue = option
                }) {
                    HStack {
                        Text(option)
                            .font(optionFont)
                            .foregroundColor(optionTextColor(for: option))
                        
                        Spacer()
                        
                        if selectedValue == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(checkmarkColor)
                        }
                    }
                    .padding(optionPadding)
                    .background(optionBackground(for: option))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func optionTextColor(for option: String) -> Color {
        let isSelected = selectedValue == option
        switch style {
        case .overlay:
            return isSelected ? .black : .white
        default:
            return isSelected ? .white : .primary
        }
    }
    
    private var checkmarkColor: Color {
        switch style {
        case .overlay: return .black
        default: return .white
        }
    }
    
    private func optionBackground(for option: String) -> some View {
        let isSelected = selectedValue == option
        let cornerRadius: CGFloat = style == .minimal ? 8 : 12
        
        return RoundedRectangle(cornerRadius: cornerRadius)
            .fill(isSelected ? accentColor : unselectedColor)
    }
    
    private var accentColor: Color {
        switch style {
        case .overlay: return .white
        default: return .blue
        }
    }
    
    private var unselectedColor: Color {
        switch style {
        case .overlay: return .white.opacity(0.2)
        case .minimal: return Color(.systemGray6)
        default: return Color(.systemGray6)
        }
    }
    
    private var optionFont: Font {
        switch style {
        case .overlay: return .body
        case .minimal: return .callout
        default: return .body
        }
    }
    
    private var optionPadding: EdgeInsets {
        switch style {
        case .minimal: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        default: return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        }
    }
}

// MARK: - Slider Element
@available(iOS 15.0, *)
struct SliderElement: View {
    let page: OnboardingPage
    @Binding var value: Double
    let style: InteractiveElement.InteractiveStyle
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(Int(value))")
                .font(valueFont)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
            
            Slider(
                value: $value,
                in: (page.min ?? 0)...(page.max ?? 100),
                step: page.step ?? 1
            ) {
                Text(page.title)
            } minimumValueLabel: {
                Text("\(Int(page.min ?? 0))")
                    .font(.caption)
                    .foregroundColor(labelColor)
            } maximumValueLabel: {
                Text("\(Int(page.max ?? 100))")
                    .font(.caption)
                    .foregroundColor(labelColor)
            }
            .accentColor(sliderAccentColor)
        }
    }
    
    private var valueFont: Font {
        switch style {
        case .overlay: return .title
        default: return .largeTitle
        }
    }
    
    private var valueColor: Color {
        switch style {
        case .overlay: return .white
        default: return .blue
        }
    }
    
    private var labelColor: Color {
        switch style {
        case .overlay: return .white.opacity(0.8)
        default: return .secondary
        }
    }
    
    private var sliderAccentColor: Color {
        switch style {
        case .overlay: return .white
        default: return .blue
        }
    }
}
