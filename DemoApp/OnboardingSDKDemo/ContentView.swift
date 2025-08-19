import SwiftUI
// import OnboardingSDK // Uncomment when using as a package

struct ContentView: View {
    @State private var showOnboarding = false
    @State private var selectedFlowID = "fitness_onboarding_v1"
    @State private var onboardingResults: [String: Any] = [:]
    @State private var showResults = false
    
    private let availableFlows = [
        "fitness_onboarding_v1": "Fitness Tracker",
        "ecommerce_onboarding_v1": "E-commerce Shop",
        "banking_onboarding_v1": "Banking App"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text("OnboardingSDK Demo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Experience dynamic onboarding flows")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                VStack(spacing: 16) {
                    Text("Choose an Onboarding Flow")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        ForEach(Array(availableFlows.keys), id: \.self) { flowID in
                            FlowSelectionCard(
                                title: availableFlows[flowID] ?? flowID,
                                flowID: flowID,
                                isSelected: selectedFlowID == flowID
                            ) {
                                selectedFlowID = flowID
                            }
                        }
                    }
                }
                
                Button("Start Onboarding") {
                    startOnboarding()
                }
                .buttonStyle(DemoButtonStyle())
                
                if !onboardingResults.isEmpty {
                    Button("View Last Results") {
                        showResults = true
                    }
                    .buttonStyle(SecondaryDemoButtonStyle())
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showOnboarding) {
            if let flow = createMockFlow(for: selectedFlowID) {
                // OnboardingView(flow: flow) { results in
                //     onboardingResults = results
                //     showOnboarding = false
                // }
                MockOnboardingView(
                    flowID: selectedFlowID,
                    flowTitle: availableFlows[selectedFlowID] ?? selectedFlowID
                ) { results in
                    onboardingResults = results
                    showOnboarding = false
                }
            }
        }
        .sheet(isPresented: $showResults) {
            ResultsView(results: onboardingResults)
        }
    }
    
    private func startOnboarding() {
        // In a real implementation, you would:
        // OnboardingSDK.shared.configure(appID: "demo_app")
        // OnboardingSDK.shared.startOnboarding(flowID: selectedFlowID) { flow in
        //     if let flow = flow {
        //         self.currentFlow = flow
        //         self.showOnboarding = true
        //     }
        // }
        
        showOnboarding = true
    }
    
    private func createMockFlow(for flowID: String) -> OnboardingFlow? {
        // This creates mock flows for demo purposes
        // In production, these would come from OnboardingSDK
        
        switch flowID {
        case "fitness_onboarding_v1":
            return OnboardingFlow(
                flowID: flowID,
                appID: "demo_app",
                version: "1.0",
                pages: [
                    OnboardingPage(
                        id: "welcome",
                        type: .textImage,
                        title: "Welcome to FitTracker",
                        subtitle: "Your journey to better health starts here"
                    ),
                    OnboardingPage(
                        id: "weight",
                        type: .input,
                        title: "What's your weight?",
                        placeholder: "70 kg",
                        inputType: .number,
                        key: "weight"
                    ),
                    OnboardingPage(
                        id: "goal",
                        type: .selector,
                        title: "What's your goal?",
                        key: "goal",
                        options: ["Lose weight", "Maintain", "Gain muscle"]
                    )
                ]
            )
        default:
            return nil
        }
    }
}

struct FlowSelectionCard: View {
    let title: String
    let flowID: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(flowID)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MockOnboardingView: View {
    let flowID: String
    let flowTitle: String
    let onCompletion: ([String: Any]) -> Void
    
    @State private var currentStep = 0
    @State private var userInputs: [String: Any] = [:]
    
    private let steps = [
        "Welcome Screen",
        "Collect Information",
        "Preferences Setup",
        "Complete Setup"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Progress
                VStack(spacing: 16) {
                    ProgressView(value: Double(currentStep + 1), total: Double(steps.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    
                    Text("Step \(currentStep + 1) of \(steps.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Content
                VStack(spacing: 24) {
                    Image(systemName: getIconForStep(currentStep))
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text(steps[currentStep])
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("This is a mock of the \(flowTitle) onboarding flow")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if currentStep == 1 {
                        VStack(spacing: 12) {
                            TextField("Sample Input", text: .constant(""))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Sample Selection", selection: .constant("Option 1")) {
                                Text("Option 1").tag("Option 1")
                                Text("Option 2").tag("Option 2")
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Navigation
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            currentStep -= 1
                        }
                        .buttonStyle(SecondaryDemoButtonStyle())
                    }
                    
                    Spacer()
                    
                    Button(currentStep == steps.count - 1 ? "Complete" : "Next") {
                        if currentStep == steps.count - 1 {
                            completeOnboarding()
                        } else {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(DemoButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(flowTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCompletion([:])
                }
            )
        }
    }
    
    private func getIconForStep(_ step: Int) -> String {
        switch step {
        case 0: return "hand.wave"
        case 1: return "pencil.and.outline"
        case 2: return "gearshape"
        case 3: return "checkmark.circle"
        default: return "circle"
        }
    }
    
    private func completeOnboarding() {
        let mockResults: [String: Any] = [
            "flow_id": flowID,
            "completed_at": Date(),
            "sample_input": "Mock Data",
            "sample_selection": "Option 1"
        ]
        onCompletion(mockResults)
    }
}

struct ResultsView: View {
    let results: [String: Any]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Onboarding Results")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    ForEach(Array(results.keys.sorted()), id: \.self) { key in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(key.capitalized)
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text("\(String(describing: results[key] ?? ""))")
                                .font(.body)
                                .padding(.leading, 8)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Spacer(minLength: 32)
                }
                .padding()
            }
            .navigationTitle("Results")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Button Styles

struct DemoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
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

struct SecondaryDemoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
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

// MARK: - Mock Models (for demo purposes)

struct OnboardingFlow {
    let flowID: String
    let appID: String
    let version: String
    let pages: [OnboardingPage]
}

struct OnboardingPage {
    let id: String
    let type: OnboardingPageType
    let title: String
    let subtitle: String?
    let imageURL: String?
    let placeholder: String?
    let inputType: InputType?
    let key: String?
    let options: [String]
    
    init(
        id: String,
        type: OnboardingPageType,
        title: String,
        subtitle: String? = nil,
        imageURL: String? = nil,
        placeholder: String? = nil,
        inputType: InputType? = nil,
        key: String? = nil,
        options: [String] = []
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.placeholder = placeholder
        self.inputType = inputType
        self.key = key
        self.options = options
    }
}

enum OnboardingPageType {
    case textImage
    case input
    case selector
    case slider
}

enum InputType {
    case text
    case number
    case email
    case password
}

#Preview {
    ContentView()
}
