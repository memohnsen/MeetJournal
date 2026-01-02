import SwiftUI
import Clerk

struct ObjectiveReviewHistoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel = ObjectiveReviewViewModel()
    @State private var expandedItems: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if viewModel.objectiveReviews.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                            
                            Text("No Previous Conversations")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("Your reframed training cues will appear here")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(viewModel.objectiveReviews) { review in
                            ObjectiveReviewCard(
                                review: review,
                                isExpanded: expandedItems.contains(reviewIdentifier(review)),
                                onToggle: {
                                    let identifier = reviewIdentifier(review)
                                    if expandedItems.contains(identifier) {
                                        expandedItems.remove(identifier)
                                    } else {
                                        expandedItems.insert(identifier)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .navigationTitle("History")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadReviews()
            }
        }
    }
    
    private func loadReviews() async {
        guard let userId = Clerk.shared.user?.id else { return }
        await viewModel.fetchObjectiveReviews(user_id: userId)
    }
    
    private func reviewIdentifier(_ review: ObjectiveReview) -> String {
        if let id = review.id {
            return "\(id)"
        }
        return review.created_at
    }
}

struct ObjectiveReviewCard: View {
    let review: ObjectiveReview
    let isExpanded: Bool
    let onToggle: () -> Void
    
    private var formattedDate: String {
        dateFormat(review.created_at) ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                Button {
                    onToggle()
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(blueEnergy)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The Athlete's Voice")
                            .font(.headline.bold())
                            .foregroundStyle(.secondary)
                        
                        Text(review.athlete_vent)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The Coach's Voice")
                            .font(.headline.bold())
                            .foregroundStyle(blueEnergy)
                        
                        Text(review.coach_reframe)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(blueEnergy.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(blueEnergy.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.top, 8)
            } else {
                Text(review.coach_reframe)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .lineSpacing(4)
            }
        }
        .cardStyling()
    }
}

#Preview {
    NavigationStack {
        ObjectiveReviewHistoryView()
    }
}

