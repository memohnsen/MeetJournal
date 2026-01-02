import SwiftUI

struct ExternalAnchorView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep: Int = 0
    @State private var userInputs: [String] = Array(repeating: "", count: 7)
    @State private var currentInput: String = ""
    @State private var transitionOffset: CGFloat = 0
    
    let steps: [StepInfo] = [
        StepInfo(
            instruction: "Take a deep breath",
            description: "Begin by taking a slow, deep breath. Inhale through your nose, hold for a moment, then exhale slowly.",
            count: nil,
            sense: nil
        ),
        StepInfo(
            instruction: "Find 5 things you can see",
            description: "Look around your environment and identify five distinct objects you can see.",
            count: 5,
            sense: "see"
        ),
        StepInfo(
            instruction: "Find 4 things you can feel",
            description: "Notice four different physical sensations you can feel right now.",
            count: 4,
            sense: "feel"
        ),
        StepInfo(
            instruction: "Find 3 things you can hear",
            description: "Listen carefully and identify three distinct sounds in your environment.",
            count: 3,
            sense: "hear"
        ),
        StepInfo(
            instruction: "Find 2 things you can smell",
            description: "Take a moment to notice two different scents or smells around you.",
            count: 2,
            sense: "smell"
        ),
        StepInfo(
            instruction: "Find 1 thing you can taste",
            description: "Notice one thing you can taste, or think of your favorite flavor if nothing is present.",
            count: 1,
            sense: "taste"
        ),
        StepInfo(
            instruction: "Take another deep breath",
            description: "Finish by taking another slow, deep breath. Remind yourself that you are safe and grounded.",
            count: nil,
            sense: nil
        )
    ]
    
    var currentStepInfo: StepInfo {
        steps[currentStep]
    }
    
    var stepColor: Color {
        switch currentStep {
        case 0:
            return Color(red: 0.85, green: 0.75, blue: 0.95)
        case 1:
            return Color(red: 0.75, green: 0.85, blue: 0.95)
        case 2:
            return Color(red: 0.70, green: 0.90, blue: 0.95)
        case 3:
            return Color(red: 0.65, green: 0.85, blue: 0.90)
        case 4:
            return Color(red: 0.60, green: 0.80, blue: 0.85)
        case 5:
            return Color(red: 0.55, green: 0.75, blue: 0.80)
        case 6:
            return Color(red: 0.80, green: 0.90, blue: 0.95)
        default:
            return Color(red: 0.75, green: 0.85, blue: 0.95)
        }
    }
    
    var backgroundGradient: LinearGradient {
        let bottomColor = colorScheme == .dark ? Color.black : Color.white
        return LinearGradient(
            colors: [stepColor, bottomColor],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: currentStep)
                
                VStack(spacing: 0) {
                    progressBar
                        .padding(.top, 16)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    stepContent
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    submitButton
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("External Anchor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .onAppear {
                currentInput = userInputs[currentStep]
            }
        }
    }
    
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index <= currentStep ? blueEnergy : Color.gray.opacity(0.3))
                    .frame(height: 6)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }
    
    private var stepContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(currentStepInfo.instruction)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(currentStepInfo.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal)
            }
            .padding(.bottom, 20)
            
            if currentStepInfo.count != nil {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your \(currentStepInfo.sense ?? "observations")")
                        .font(.headline.bold())
                    
                    TextField(
                        "List \(currentStepInfo.count ?? 0) things...",
                        text: $currentInput,
                        axis: .vertical
                    )
                    .lineLimit(5...10)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .light ? .white.opacity(0.9) : Color.black.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(blueEnergy.opacity(0.3), lineWidth: 1)
                    )
                }
                .cardStyling()
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "wind")
                        .font(.system(size: 60))
                        .foregroundStyle(blueEnergy.opacity(0.6))
                        .symbolEffect(.pulse, options: .repeating)
                }
                .frame(height: 120)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .id(currentStep)
    }
    
    private var submitButton: some View {
        Button {
            handleSubmit()
        } label: {
            HStack(spacing: 8) {
                if currentStep < 6 {
                    Text("Continue")
                } else {
                    Text("Complete")
                }
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(blueEnergy)
            .clipShape(.rect(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .disabled(currentStepInfo.count != nil && currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(currentStepInfo.count != nil && currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
    }
    
    private func handleSubmit() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        if currentStepInfo.count != nil {
            userInputs[currentStep] = currentInput
        }
        
        if currentStep < 6 {
            withAnimation(.easeInOut(duration: 0.4)) {
                currentStep += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentInput = userInputs[currentStep]
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dismiss()
            }
        }
    }
}

struct StepInfo {
    let instruction: String
    let description: String
    let count: Int?
    let sense: String?
}

#Preview {
    ExternalAnchorView()
}

