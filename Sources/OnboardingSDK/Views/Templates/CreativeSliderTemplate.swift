import SwiftUI

/// Creative slider template with side image and custom styling
@available(iOS 15.0, *)
struct CreativeSliderTemplate: View {
    let page: OnboardingPage
    @Binding var userInputs: [String: Any]
    let onInputChange: (String, Any) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Header with optional image
            HStack(spacing: 20) {
                if let imageURL = page.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .overlay(
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.green)
                            )
                    }
                    .frame(width: imageSize.width, height: imageSize.height)
                    .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(page.title)
                        .font(titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(titleColor)
                    
                    if let subtitle = page.subtitle {
                        Text(subtitle)
                            .font(subtitleFont)
                            .foregroundColor(subtitleColor)
                    }
                }
                
                Spacer()
            }
            
            // Creative slider section
            if page.type == .slider {
                CreativeSliderElement(
                    page: page,
                    value: sliderBinding
                )
            }
        }
        .padding(contentPadding)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Bindings & Computed Properties
    
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
    
    private var imageSize: (width: CGFloat, height: CGFloat) {
        let width = page.style?.imageSize?.width ?? 80
        let height = page.style?.imageSize?.height ?? 80
        return (CGFloat(width), CGFloat(height))
    }
    
    private var titleFont: Font {
        if let size = page.style?.titleFontSize {
            return .system(size: size, weight: .bold)
        }
        return .title2
    }
    
    private var subtitleFont: Font {
        if let size = page.style?.subtitleFontSize {
            return .system(size: size, weight: .medium)
        }
        return .body
    }
    
    private var titleColor: Color {
        Color(hex: page.style?.titleColor) ?? .primary
    }
    
    private var subtitleColor: Color {
        Color(hex: page.style?.subtitleColor) ?? .secondary
    }
    
    private var backgroundColor: Color {
        Color(hex: page.style?.backgroundColor) ?? Color(.systemBackground)
    }
    
    private var contentPadding: EdgeInsets {
        let style = page.style
        return EdgeInsets(
            top: style?.padding?.top ?? 32,
            leading: style?.padding?.leading ?? 24,
            bottom: style?.padding?.bottom ?? 32,
            trailing: style?.padding?.trailing ?? 24
        )
    }
}

// MARK: - Creative Slider Element
@available(iOS 15.0, *)
struct CreativeSliderElement: View {
    let page: OnboardingPage
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 24) {
            // Large value display with currency
            HStack {
                Text("$")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("\(Int(value))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                Text("/ month")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Custom styled slider
            VStack(spacing: 12) {
                Slider(
                    value: $value,
                    in: (page.min ?? 0)...(page.max ?? 500),
                    step: page.step ?? 25
                )
                .accentColor(sliderAccentColor)
                
                // Range labels
                HStack {
                    Text("$\(Int(page.min ?? 0))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(Int(page.max ?? 500))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Helpful range indicators
            HStack(spacing: 8) {
                ForEach(budgetRanges, id: \.label) { range in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            value = range.value
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(range.emoji)
                                .font(.title3)
                            Text(range.label)
                                .font(.caption2)
                                .foregroundColor(value == range.value ? accentColor : .secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(value == range.value ? accentColor.opacity(0.2) : Color.white.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var budgetRanges: [(emoji: String, label: String, value: Double)] {
        [
            ("🌱", "Starter", page.min ?? 0),
            ("💝", "Casual", 100),
            ("🎯", "Focused", 250),
            ("💎", "Collector", page.max ?? 500)
        ]
    }
    
    private var accentColor: Color {
        // Use white for colored backgrounds, or extract from style
        if backgroundColor != Color(.systemBackground) {
            return .white
        }
        return .green
    }
    
    private var sliderAccentColor: Color {
        return accentColor
    }
    
    private var backgroundColor: Color {
        Color(hex: page.style?.backgroundColor) ?? Color(.systemBackground)
    }
}
