import SwiftUI
import Foundation

// MARK: - Environment Key for Geometry

private struct CraftGeometryKey: EnvironmentKey {
    static let defaultValue: GeometryProxy? = nil
}

extension EnvironmentValues {
    var craftGeometry: GeometryProxy? {
        get { self[CraftGeometryKey.self] }
        set { self[CraftGeometryKey.self] = newValue }
    }
}

/// Renders Craft.js content natively in SwiftUI
@available(iOS 15.0, *)
struct CraftContentRenderer: View {
    let craftContent: String
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        if let craftData = parseCraftContent() {
            CraftNodeRenderer(
                nodeData: craftData,
                rootNodeId: "ROOT",
                page: page,
                viewModel: viewModel
            )
        } else {
            // Fallback if Craft.js parsing fails
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Unable to render custom layout")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
        }
    }
    
    private func parseCraftContent() -> [String: CraftNode]? {
        guard let data = craftContent.data(using: .utf8) else { return nil }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            var craftNodes: [String: CraftNode] = [:]
            
            // Parse each node in the Craft.js structure
            for (nodeId, nodeData) in json ?? [:] {
                if let nodeDict = nodeData as? [String: Any] {
                    craftNodes[nodeId] = CraftNode(from: nodeDict)
                }
            }
            
            return craftNodes
        } catch {
            print("CraftContentRenderer: Failed to parse Craft.js content: \(error)")
            return nil
        }
    }
}

/// Individual Craft.js node renderer
@available(iOS 15.0, *)
struct CraftNodeRenderer: View {
    let nodeData: [String: CraftNode]
    let rootNodeId: String
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        if let rootNode = nodeData[rootNodeId] {
            // Special handling for ROOT node - create layout with positioned elements
            if rootNodeId == "ROOT" {
                createRootLayout(rootNode)
            } else {
                renderNode(rootNode)
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func createRootLayout(_ rootNode: CraftNode) -> some View {
        ZStack {
            // Background layer - normal flow content
            ScrollView {
                VStack(spacing: CGFloat(viewModel.mediumSpacing)) {
                    ForEach(rootNode.childNodes, id: \.self) { childId in
                        if let childNode = nodeData[childId],
                           !isPositioned(childNode) {
                            CraftNodeRenderer(
                                nodeData: nodeData,
                                rootNodeId: childId,
                                page: page,
                                viewModel: viewModel
                            )
                        }
                    }
                }
                .padding(.horizontal, viewModel.mediumSpacing)
                .padding(.top, viewModel.largeSpacing)
                .padding(.bottom, 100) // Space for bottom positioned elements
            }
            
            // Positioned elements layer
            ForEach(rootNode.childNodes, id: \.self) { childId in
                if let childNode = nodeData[childId],
                   isPositioned(childNode) {
                    createPositionedElement(childNode, childId: childId)
                }
            }
        }
    }
    
    @ViewBuilder
    private func createPositionedElement(_ node: CraftNode, childId: String) -> some View {
        let position = getElementPosition(node)
        
        VStack {
            if position == "bottom" {
                Spacer()
                CraftNodeRenderer(
                    nodeData: nodeData,
                    rootNodeId: childId,
                    page: page,
                    viewModel: viewModel
                )
            } else if position == "top" {
                CraftNodeRenderer(
                    nodeData: nodeData,
                    rootNodeId: childId,
                    page: page,
                    viewModel: viewModel
                )
                Spacer()
            } else {
                Spacer()
                CraftNodeRenderer(
                    nodeData: nodeData,
                    rootNodeId: childId,
                    page: page,
                    viewModel: viewModel
                )
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func isPositioned(_ node: CraftNode) -> Bool {
        return node.props["pagePosition"] != nil
    }
    
    private func getElementPosition(_ node: CraftNode) -> String {
        return node.props["pagePosition"] as? String ?? "default"
    }
    
    @ViewBuilder
    private func renderNode(_ node: CraftNode) -> some View {
        let componentType = node.type.resolvedName ?? node.type.name ?? "unknown"
        
        Group {
            switch componentType {
            case "HeaderText":
                HeaderTextComponent(node: node, viewModel: viewModel)
                
            case "BodyText":
                BodyTextComponent(node: node, viewModel: viewModel)
                
            case "ImageComponent":
                ImageComponent(node: node, viewModel: viewModel)
                
            case "ButtonComponent":
                ButtonComponent(node: node, page: page, viewModel: viewModel)
                
            case "NavigationButton":
                NavigationButtonComponent(node: node, page: page, viewModel: viewModel)
                
            case "Stack":
                StackComponent(node: node, nodeData: nodeData, page: page, viewModel: viewModel)
                
            case "SelectorComponent":
                SelectorComponent(node: node, page: page, viewModel: viewModel)
                
            case "InputFieldComponent":
                InputFieldComponent(node: node, page: page, viewModel: viewModel)
                
            case "SliderComponent":
                SliderComponent(node: node, page: page, viewModel: viewModel)
                
            case "SpacerComponent":
                SpacerComponent(node: node)
                
            default:
                // Render container with children if it has any
                if !node.childNodes.isEmpty {
                    VStack(spacing: CGFloat(viewModel.mediumSpacing)) {
                        ForEach(node.childNodes, id: \.self) { childId in
                            if let childNode = nodeData[childId] {
                                CraftNodeRenderer(
                                    nodeData: nodeData,
                                    rootNodeId: childId,
                                    page: page,
                                    viewModel: viewModel
                                )
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Craft.js Data Models

struct CraftNode {
    let type: CraftNodeType
    let props: [String: Any]
    let childNodes: [String]
    let isCanvas: Bool
    
    init(from dict: [String: Any]) {
        // Parse type
        if let typeDict = dict["type"] as? [String: Any] {
            self.type = CraftNodeType(
                name: typeDict["name"] as? String,
                resolvedName: typeDict["resolvedName"] as? String
            )
        } else if let typeString = dict["type"] as? String {
            self.type = CraftNodeType(name: typeString, resolvedName: nil)
        } else {
            self.type = CraftNodeType(name: nil, resolvedName: nil)
        }
        
        // Parse props
        self.props = dict["props"] as? [String: Any] ?? [:]
        
        // Parse child nodes
        self.childNodes = dict["nodes"] as? [String] ?? []
        
        // Parse canvas flag
        self.isCanvas = dict["isCanvas"] as? Bool ?? false
    }
}

struct CraftNodeType {
    let name: String?
    let resolvedName: String?
}

// MARK: - SwiftUI Component Renderers

@available(iOS 15.0, *)
struct HeaderTextComponent: View {
    let node: CraftNode
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(textColor)
            .multilineTextAlignment(alignment)
            .padding(padding)
    }
    
    private var text: String {
        node.props["text"] as? String ?? "Header"
    }
    
    private var fontSize: CGFloat {
        CGFloat(node.props["fontSize"] as? Double ?? 28)
    }
    
    private var textColor: Color {
        if let colorString = node.props["color"] as? String {
            return Color(hex: colorString) ?? viewModel.templateTextColor
        }
        return viewModel.templateTextColor
    }
    
    private var alignment: TextAlignment {
        switch node.props["alignment"] as? String {
        case "center": return .center
        case "trailing", "right": return .trailing
        default: return .leading
        }
    }
    
    private var padding: EdgeInsets {
        if let paddingDict = node.props["padding"] as? [String: Any] {
            return EdgeInsets(
                top: CGFloat(paddingDict["top"] as? Double ?? 8),
                leading: CGFloat(paddingDict["left"] as? Double ?? 16),
                bottom: CGFloat(paddingDict["bottom"] as? Double ?? 8),
                trailing: CGFloat(paddingDict["right"] as? Double ?? 16)
            )
        }
        return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    }
}

@available(iOS 15.0, *)
struct BodyTextComponent: View {
    let node: CraftNode
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .regular))
            .foregroundColor(textColor)
            .multilineTextAlignment(alignment)
            .padding(padding)
    }
    
    private var text: String {
        node.props["text"] as? String ?? "Body text"
    }
    
    private var fontSize: CGFloat {
        CGFloat(node.props["fontSize"] as? Double ?? 17)
    }
    
    private var textColor: Color {
        if let colorString = node.props["color"] as? String {
            return Color(hex: colorString) ?? viewModel.templateTextColor
        }
        return viewModel.templateTextColor
    }
    
    private var alignment: TextAlignment {
        switch node.props["alignment"] as? String {
        case "center": return .center
        case "trailing", "right": return .trailing
        default: return .leading
        }
    }
    
    private var padding: EdgeInsets {
        if let paddingDict = node.props["padding"] as? [String: Any] {
            return EdgeInsets(
                top: CGFloat(paddingDict["top"] as? Double ?? 4),
                leading: CGFloat(paddingDict["left"] as? Double ?? 16),
                bottom: CGFloat(paddingDict["bottom"] as? Double ?? 4),
                trailing: CGFloat(paddingDict["right"] as? Double ?? 16)
            )
        }
        return EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
    }
}

@available(iOS 15.0, *)
struct ImageComponent: View {
    let node: CraftNode
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        if let urlString = node.props["src"] as? String,
           let url = URL(string: urlString) {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: viewModel.templateCornerRadius))
            } placeholder: {
                ProgressView()
                    .frame(width: width, height: height)
            }
        } else {
            RoundedRectangle(cornerRadius: viewModel.templateCornerRadius)
                .fill(Color.gray.opacity(0.3))
                .frame(width: width, height: height)
                .overlay(
                    Text("🖼️")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
        }
    }
    
    private var width: CGFloat? {
        if let w = node.props["width"] as? Double {
            return CGFloat(w)
        }
        return nil
    }
    
    private var height: CGFloat? {
        if let h = node.props["height"] as? Double {
            return CGFloat(h)
        }
        return 200 // Default height
    }
}

@available(iOS 15.0, *)
struct ButtonComponent: View {
    let node: CraftNode
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        Button(action: {
            // Move to next page
            if viewModel.canGoForward {
                viewModel.currentPageIndex += 1
            } else if viewModel.isLastPage {
                // Complete onboarding
                viewModel.finishOnboarding()
            }
        }) {
            Text(text)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(textColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: maxWidth)
                .frame(minHeight: minHeight)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
        }
        .padding(buttonPadding)
    }
    
    private var maxWidth: CGFloat? {
        if let widthProp = node.props["width"] as? String {
            return widthProp == "auto" ? nil : .infinity
        }
        return .infinity // Default to full width
    }
    
    private var minHeight: CGFloat {
        CGFloat(node.props["minHeight"] as? Double ?? 44) // iOS standard button height
    }
    
    private var fontSize: CGFloat {
        CGFloat(node.props["fontSize"] as? Double ?? 17) // iOS standard button font size
    }
    
    private var horizontalPadding: CGFloat {
        CGFloat(node.props["paddingHorizontal"] as? Double ?? 16)
    }
    
    private var verticalPadding: CGFloat {
        CGFloat(node.props["paddingVertical"] as? Double ?? 12)
    }
    
    private var buttonPadding: EdgeInsets {
        if let paddingDict = node.props["margin"] as? [String: Any] {
            return EdgeInsets(
                top: CGFloat(paddingDict["top"] as? Double ?? 0),
                leading: CGFloat(paddingDict["left"] as? Double ?? 0),
                bottom: CGFloat(paddingDict["bottom"] as? Double ?? 0),
                trailing: CGFloat(paddingDict["right"] as? Double ?? 0)
            )
        }
        return EdgeInsets()
    }
    
    private var text: String {
        node.props["text"] as? String ?? "Continue"
    }
    
    private var backgroundColor: Color {
        if let colorString = node.props["backgroundColor"] as? String {
            return Color(hex: colorString) ?? viewModel.templatePrimaryColor
        }
        return viewModel.templatePrimaryColor
    }
    
    private var textColor: Color {
        if let colorString = node.props["textColor"] as? String {
            return Color(hex: colorString) ?? Color.white
        }
        return Color.white
    }
    
    private var cornerRadius: CGFloat {
        CGFloat(node.props["borderRadius"] as? Double ?? Double(viewModel.templateCornerRadius))
    }
}

@available(iOS 15.0, *)
struct NavigationButtonComponent: View {
    let node: CraftNode
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        Button(action: {
            handleNavigationAction()
        }) {
            HStack(spacing: 8) {
                // Back icon on left for back action
                if action == "back" && !iconName.isEmpty {
                    Text(iconSymbol)
                        .font(.system(size: fontSize * 1.2, weight: .medium))
                        .foregroundColor(textColor)
                }
                
                // Button text
                if !text.isEmpty {
                    Text(text)
                        .font(.system(size: fontSize, weight: .semibold))
                        .foregroundColor(textColor)
                }
                
                // Forward icon on right for next/finish actions
                if (action == "next" || action == "finish") && !iconName.isEmpty {
                    Text(iconSymbol)
                        .font(.system(size: fontSize * 1.2, weight: .medium))
                        .foregroundColor(textColor)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: frameMaxWidth)
            .frame(minHeight: minHeight)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                // Border for secondary type
                buttonType == "secondary" ? 
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(viewModel.templatePrimaryColor, lineWidth: 2)
                : nil
            )
        }
        .padding(buttonPadding)
    }
    
    private func handleNavigationAction() {
        switch action {
        case "back":
            if viewModel.canGoBack {
                viewModel.goBack()
            }
        case "next":
            if viewModel.canGoForward {
                viewModel.goForward()
            }
        case "finish":
            if viewModel.isLastPage {
                viewModel.finishOnboarding()
            }
        default:
            break
        }
    }
    
    private var text: String {
        node.props["text"] as? String ?? "Continue"
    }
    
    private var buttonType: String {
        node.props["type"] as? String ?? "primary"
    }
    
    private var action: String {
        node.props["action"] as? String ?? "next"
    }
    
    private var iconName: String {
        node.props["icon"] as? String ?? ""
    }
    
    private var iconSymbol: String {
        let iconMap: [String: String] = [
            "chevron.left": "‹",
            "chevron.right": "›", 
            "arrow.left": "←",
            "arrow.right": "→",
            "checkmark": "✓",
            "xmark": "✕"
        ]
        return iconMap[iconName] ?? iconName
    }
    
    private var backgroundColor: Color {
        switch buttonType {
        case "primary":
            if let colorString = node.props["backgroundColor"] as? String {
                return Color(hex: colorString) ?? viewModel.templatePrimaryColor
            }
            return viewModel.templatePrimaryColor
        case "secondary":
            return Color.clear
        case "text":
            return Color.clear
        default:
            return viewModel.templatePrimaryColor
        }
    }
    
    private var textColor: Color {
        switch buttonType {
        case "primary":
            if let colorString = node.props["textColor"] as? String {
                return Color(hex: colorString) ?? Color.white
            }
            return Color.white
        case "secondary", "text":
            if let colorString = node.props["backgroundColor"] as? String {
                return Color(hex: colorString) ?? viewModel.templatePrimaryColor
            }
            return viewModel.templatePrimaryColor
        default:
            return Color.white
        }
    }
    
    private var fontSize: CGFloat {
        CGFloat(node.props["fontSize"] as? Double ?? 17)
    }
    
    private var cornerRadius: CGFloat {
        CGFloat(node.props["borderRadius"] as? Double ?? Double(viewModel.templateCornerRadius))
    }
    
    private var horizontalPadding: CGFloat {
        if let paddingDict = node.props["padding"] as? [String: Any] {
            return CGFloat(paddingDict["left"] as? Double ?? 24)
        }
        return 24
    }
    
    private var verticalPadding: CGFloat {
        if let paddingDict = node.props["padding"] as? [String: Any] {
            return CGFloat(paddingDict["top"] as? Double ?? 16)
        }
        return 16
    }
    
    private var minHeight: CGFloat {
        CGFloat(44) // iOS standard button height
    }
    
    private var frameMaxWidth: CGFloat? {
        if let widthString = node.props["width"] as? String {
            return widthString == "100%" ? .infinity : nil
        }
        return .infinity
    }
    
    private var buttonPadding: EdgeInsets {
        if let marginDict = node.props["margin"] as? [String: Any] {
            return EdgeInsets(
                top: CGFloat(marginDict["top"] as? Double ?? 0),
                leading: CGFloat(marginDict["left"] as? Double ?? 0),
                bottom: CGFloat(marginDict["bottom"] as? Double ?? 0),
                trailing: CGFloat(marginDict["right"] as? Double ?? 0)
            )
        }
        return EdgeInsets()
    }
}

@available(iOS 15.0, *)
struct StackComponent: View {
    let node: CraftNode
    let nodeData: [String: CraftNode]
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    var body: some View {
        if direction == "horizontal" {
            HStack(alignment: verticalAlignment, spacing: spacing) {
                ForEach(node.childNodes, id: \.self) { childId in
                    if let childNode = nodeData[childId] {
                        CraftNodeRenderer(
                            nodeData: nodeData,
                            rootNodeId: childId,
                            page: page,
                            viewModel: viewModel
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: Alignment(horizontal: horizontalAlignment, vertical: .center))
            .frame(minHeight: minHeight)
            .padding(stackPadding)
        } else {
            VStack(alignment: horizontalAlignment, spacing: spacing) {
                ForEach(node.childNodes, id: \.self) { childId in
                    if let childNode = nodeData[childId] {
                        CraftNodeRenderer(
                            nodeData: nodeData,
                            rootNodeId: childId,
                            page: page,
                            viewModel: viewModel
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: minHeight)
            .padding(stackPadding)
        }
    }
    
    private var direction: String {
        node.props["direction"] as? String ?? "vertical"
    }
    
    private var spacing: CGFloat {
        CGFloat(node.props["spacing"] as? Double ?? Double(viewModel.mediumSpacing))
    }
    
    private var minHeight: CGFloat {
        CGFloat(node.props["minHeight"] as? Double ?? 100)
    }
    
    private var horizontalAlignment: HorizontalAlignment {
        switch node.props["alignItems"] as? String {
        case "center": return .center
        case "trailing", "flex-end": return .trailing
        default: return .leading
        }
    }
    
    private var verticalAlignment: VerticalAlignment {
        switch node.props["alignItems"] as? String {
        case "center": return .center
        case "bottom", "flex-end": return .bottom
        default: return .top
        }
    }
    
    private var stackPadding: EdgeInsets {
        if let paddingDict = node.props["padding"] as? [String: Any] {
            return EdgeInsets(
                top: CGFloat(paddingDict["top"] as? Double ?? 0),
                leading: CGFloat(paddingDict["left"] as? Double ?? 0),
                bottom: CGFloat(paddingDict["bottom"] as? Double ?? 0),
                trailing: CGFloat(paddingDict["right"] as? Double ?? 0)
            )
        }
        return EdgeInsets()
    }
}

@available(iOS 15.0, *)
struct SelectorComponent: View {
    let node: CraftNode
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        VStack(spacing: viewModel.smallSpacing) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button(action: {
                    selectedIndex = index
                    if let key = page.key {
                        viewModel.updateUserInput(key: key, value: option)
                    }
                }) {
                    Text(option)
                        .foregroundColor(index == selectedIndex ? selectedTextColor : textColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(index == selectedIndex ? selectedBackgroundColor : backgroundColor)
                        .cornerRadius(cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(borderColor, lineWidth: 1)
                        )
                }
            }
        }
    }
    
    private var options: [String] {
        node.props["options"] as? [String] ?? page.options ?? ["Option 1", "Option 2"]
    }
    
    private var backgroundColor: Color {
        if let colorString = node.props["backgroundColor"] as? String {
            return Color(hex: colorString) ?? Color.gray.opacity(0.1)
        }
        return Color.gray.opacity(0.1)
    }
    
    private var selectedBackgroundColor: Color {
        if let colorString = node.props["selectedBackgroundColor"] as? String {
            return Color(hex: colorString) ?? viewModel.templatePrimaryColor
        }
        return viewModel.templatePrimaryColor
    }
    
    private var textColor: Color {
        if let colorString = node.props["textColor"] as? String {
            return Color(hex: colorString) ?? viewModel.templateTextColor
        }
        return viewModel.templateTextColor
    }
    
    private var selectedTextColor: Color {
        if let colorString = node.props["selectedTextColor"] as? String {
            return Color(hex: colorString) ?? Color.white
        }
        return Color.white
    }
    
    private var borderColor: Color {
        if let colorString = node.props["borderColor"] as? String {
            return Color(hex: colorString) ?? Color.gray.opacity(0.3)
        }
        return Color.gray.opacity(0.3)
    }
    
    private var cornerRadius: CGFloat {
        CGFloat(node.props["borderRadius"] as? Double ?? Double(viewModel.templateCornerRadius))
    }
}

@available(iOS 15.0, *)
struct InputFieldComponent: View {
    let node: CraftNode
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    @State private var inputValue: String = ""
    
    var body: some View {
        TextField(placeholder, text: $inputValue)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .font(.system(size: fontSize))
            .padding(padding)
            .onChange(of: inputValue) { newValue in
                if let key = page.key {
                    viewModel.updateUserInput(key: key, value: newValue)
                }
            }
    }
    
    private var placeholder: String {
        node.props["placeholder"] as? String ?? page.placeholder ?? "Enter text"
    }
    
    private var fontSize: CGFloat {
        CGFloat(node.props["fontSize"] as? Double ?? 16)
    }
    
    private var padding: EdgeInsets {
        if let paddingDict = node.props["padding"] as? [String: Any] {
            return EdgeInsets(
                top: CGFloat(paddingDict["top"] as? Double ?? 0),
                leading: CGFloat(paddingDict["left"] as? Double ?? 0),
                bottom: CGFloat(paddingDict["bottom"] as? Double ?? 0),
                trailing: CGFloat(paddingDict["right"] as? Double ?? 0)
            )
        }
        return EdgeInsets()
    }
}

@available(iOS 15.0, *)
struct SliderComponent: View {
    let node: CraftNode
    let page: EnhancedOnboardingPage
    @ObservedObject var viewModel: EnhancedOnboardingViewModel
    
    @State private var sliderValue: Double = 50
    
    var body: some View {
        VStack(spacing: viewModel.smallSpacing) {
            HStack {
                Text("\(Int(minValue))")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(maxValue))")
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $sliderValue, in: minValue...maxValue, step: stepValue)
                .accentColor(thumbColor)
                .onChange(of: sliderValue) { newValue in
                    if let key = page.key {
                        viewModel.updateUserInput(key: key, value: newValue)
                    }
                }
            
            Text("\(Int(sliderValue))")
                .font(.headline)
                .foregroundColor(viewModel.templateTextColor)
        }
        .onAppear {
            sliderValue = node.props["value"] as? Double ?? 50
        }
    }
    
    private var minValue: Double {
        node.props["min"] as? Double ?? page.min ?? 0
    }
    
    private var maxValue: Double {
        node.props["max"] as? Double ?? page.max ?? 100
    }
    
    private var stepValue: Double {
        node.props["step"] as? Double ?? page.step ?? 1
    }
    
    private var thumbColor: Color {
        if let colorString = node.props["thumbColor"] as? String {
            return Color(hex: colorString) ?? viewModel.templatePrimaryColor
        }
        return viewModel.templatePrimaryColor
    }
}

@available(iOS 15.0, *)
struct SpacerComponent: View {
    let node: CraftNode
    
    var body: some View {
        Spacer()
            .frame(height: height)
    }
    
    private var height: CGFloat {
        CGFloat(node.props["height"] as? Double ?? 16)
    }
}


