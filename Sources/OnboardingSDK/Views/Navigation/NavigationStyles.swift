import SwiftUI

/// Enhanced button style that applies the configuration
@available(iOS 15.0, *)
public struct NavigationButtonStyle: ButtonStyle {
    let config: NavigationButtonConfig
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    public func makeBody(configuration: Configuration) -> some View {
        Group {
            switch config.type {
            case .circle, .fab:
                configuration.label
                    .background(circleBackground)
                    .clipShape(Circle())
                    .shadow(radius: config.elevation ?? 0)
                    
            case .pill, .rectangle:
                configuration.label
                    .background(rectangleBackground)
                    .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius ?? 8))
                    .shadow(radius: config.elevation ?? 0)
                    
            case .text, .invisible:
                configuration.label
                    .background(Color.clear)
            }
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    @ViewBuilder
    private var circleBackground: some View {
        Circle()
            .fill(viewModel.primaryButtonBackgroundColor)
            .frame(width: config.size ?? 44, height: config.size ?? 44)
    }
    
    @ViewBuilder
    private var rectangleBackground: some View {
        switch config.type {
        case .pill:
            RoundedRectangle(cornerRadius: config.cornerRadius ?? 25)
                .fill(viewModel.primaryButtonBackgroundColor)
                .frame(height: config.size ?? 50)
                
        case .rectangle:
            RoundedRectangle(cornerRadius: config.cornerRadius ?? 8)
                .fill(viewModel.primaryButtonBackgroundColor)
                .frame(height: config.size ?? 48)
                
        default:
            Color.clear
        }
    }
}

/// View extension for positioning buttons
@available(iOS 15.0, *)
extension View {
    public func position(for position: ButtonPosition) -> some View {
        GeometryReader { geometry in
            self
                .position(
                    x: xPosition(for: position, in: geometry),
                    y: yPosition(for: position, in: geometry)
                )
        }
    }
    
    private func xPosition(for position: ButtonPosition, in geometry: GeometryProxy) -> CGFloat {
        switch position {
        case .bottomLeading, .topLeading, .centerLeading, .floatingLeft:
            return geometry.size.width * 0.15
        case .bottomTrailing, .topTrailing, .centerTrailing, .floatingRight:
            return geometry.size.width * 0.85
        case .bottomCenter:
            return geometry.size.width * 0.5
        }
    }
    
    private func yPosition(for position: ButtonPosition, in geometry: GeometryProxy) -> CGFloat {
        switch position {
        case .topLeading, .topTrailing:
            return geometry.size.height * 0.1
        case .centerLeading, .centerTrailing:
            return geometry.size.height * 0.5
        case .floatingLeft, .floatingRight:
            return geometry.size.height * 0.85
        case .bottomLeading, .bottomTrailing, .bottomCenter:
            return geometry.size.height * 0.92
        }
    }
}
