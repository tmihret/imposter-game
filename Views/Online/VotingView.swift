import SwiftUI

struct VotingView: View {
    @ObservedObject var vm: OnlineGameViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ──
            VStack(spacing: 6) {
                Text("🗳️ Vote!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.primaryText)
                Text("\(vm.gameService.alivePlayers.filter { $0.hasVoted }.count) of \(vm.alivePlayers.count) voted")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.vertical, 20)
            
            // ── Player List ──
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(vm.alivePlayers) { player in
                        if player.id != vm.currentPlayer?.id {
                            VotePlayerRow(
                                player: player,
                                isSelected: vm.myVote == player.id,
                                hasVoted: vm.myVote != nil,
                                voteCount: vm.voteCounts[player.id ?? ""] ?? 0,
                                showVoteCounts: vm.allVotesCast
                            ) {
                                Task {
                                    try? await vm.castVote(
                                        for: player.id ?? ""
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(AppTheme.background)
            
            Divider()
                .background(AppTheme.cardBackground)
            
            // ── Chat log (read only) ──
            ChatView(
                chatService: vm.chatService,
                gameId: vm.gameId,
                isLocked: true
            )
            .frame(maxHeight: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
}

struct VotePlayerRow: View {
    let player: Player
    let isSelected: Bool
    let hasVoted: Bool
    let voteCount: Int
    let showVoteCounts: Bool
    let onVote: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(isSelected ? AppTheme.accent : AppTheme.cardBackground)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(player.name.prefix(1)))
                        .font(.headline)
                        .foregroundStyle(isSelected ? .white : AppTheme.primaryText)
                )
            
            Text(player.name)
                .font(.body.bold())
                .foregroundStyle(AppTheme.primaryText)
            
            Spacer()
            
            // Show vote counts after all voted
            if showVoteCounts {
                HStack(spacing: 4) {
                    Image(systemName: "hand.raised.fill")
                    Text("\(voteCount)")
                }
                .foregroundStyle(.orange)
                .font(.subheadline.bold())
            }
            
            // Vote button or checkmark
            if !hasVoted {
                Button("Vote") { onVote() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
            } else if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.accent)
                    .font(.title2)
            }
        }
        .padding()
        .background(isSelected
                    ? AppTheme.accent.opacity(0.1) : AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppTheme.accent : Color.clear,
                        lineWidth: 2)
        )
    }
}
