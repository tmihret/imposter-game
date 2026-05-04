import SwiftUI

struct OnlineGameView: View {
    let gameId: String
    @StateObject private var vm: OnlineGameViewModel
    
    init(gameId: String, gameService: GameService) {
        self.gameId = gameId
        _vm = StateObject(
            wrappedValue: OnlineGameViewModel(
                gameId: gameId,
                gameService: gameService
            )
        )
    }
    
    var body: some View {
        Group {
            switch vm.currentStatus {
            case .playing:
                DiscussionOnlineView(vm: vm)
                    .transition(.opacity)
            case .voting:
                VotingView(vm: vm)
                    .transition(.opacity)
            case .results:
                OnlineResultsView(vm: vm)
                    .transition(.opacity)
            case .ended:
                OnlineGameOverView(vm: vm)
                    .transition(.opacity)
            default:
                WaitingForGameView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.currentStatus)
        .onChange(of: vm.currentStatus) { newStatus in
            print("🔄 View switching to: \(newStatus)")
        }
        .onAppear {
            print("🔄 OnlineGameView appeared")
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .navigationBarBackButtonHidden(true)
    }
}

// ── Discussion Phase ──
struct DiscussionOnlineView: View {
    @ObservedObject var vm: OnlineGameViewModel
    @State private var showWord = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Word peek card ──
            VStack(spacing: 6) {
                Text("Category: \(vm.game.category)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                
                if showWord {
                    Text(vm.currentPlayer?.word ?? "???")
                        .font(.title.bold())
                        .foregroundStyle(AppTheme.primaryText)
                } else {
                    Text("Tap to peek at your word")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                withAnimation(.spring()) {
                    showWord.toggle()
                }
            }
            .padding()
            .padding(.top, 8)
            
            // ── Timer ──
            TimerRingView(
                timeLeft: vm.discussionTimeLeft,
                total: 180
            )
            .frame(width: 150, height: 150)
            .padding(.bottom, 8)
            
            // ── Chat ──
            ChatView(
                chatService: vm.chatService,
                gameId: vm.gameId,
                isLocked: false
            )
            
            // ── Host controls ──
            if vm.isHost {
                Button {
                    Task {
                        do {
                            try await vm.moveToVoting()
                        } catch {
                            print("❌ Move to voting error: \(error)")
                        }
                    }
                } label: {
                    Text("Start Voting Now")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)   // ← dot added
        .onAppear {
            vm.startDiscussionTimer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

// ── Waiting screen ──
struct WaitingForGameView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(AppTheme.accent)
            Text("Loading game...")
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)   // ← dot added
    }
}
