import SwiftUI

struct WaitingRoomView: View {
    let gameId: String
    @ObservedObject var gameService: GameService
    @StateObject private var chatService = ChatService()
    @State private var navigateToGame = false
    @State private var isStarting = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            
            // ── Header ──
            VStack(spacing: 8) {
                Text("Waiting Room")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.primaryText)
                
                VStack(spacing: 4) {
                    Text("Join Code")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(gameService.game.code)
                        .font(.system(size: 36,
                                      weight: .black,
                                      design: .monospaced))
                        .foregroundStyle(AppTheme.accent)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 32)
            
            // ── Player List ──
            VStack(alignment: .leading, spacing: 12) {
                Text("\(gameService.players.count) Players Joined")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(gameService.players) { player in
                            HStack {
                                Circle()
                                    .fill(AppTheme.accent.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(
                                            player.name.prefix(1)
                                        ))
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.accent)
                                    )
                                
                                Text(player.name)
                                    .font(.body.bold())
                                    .foregroundStyle(AppTheme.primaryText)
                                
                                Spacer()
                                
                                if player.id == gameService.game.hostId {
                                    Text("HOST")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.accent)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // ── Error ──
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(AppTheme.accent)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            // ── Minimum players warning ──
            if gameService.players.count < 2 {
                Text("Need \(2 - gameService.players.count) more player(s) to start")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }
            
            // ── Start button (host only) ──
            if gameService.isHost {
                Button {
                    Task { await startGame() }
                } label: {
                    HStack {
                        if isStarting {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 8)
                        }
                        Text(isStarting ? "Starting..." : "Start Game")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        gameService.players.count >= 2
                            ? AppTheme.accent : Color.gray
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(gameService.players.count < 2 || isStarting)
                .padding(.horizontal)
            } else {
                Text("Waiting for host to start...")
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer().frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("🔄 WaitingRoom appeared - gameId: \(gameId)")
            navigateToGame = false   // ← reset on appear
            gameService.listenToGame(gameId: gameId)
        }
        .onDisappear {
            if !navigateToGame {
                gameService.stopListening()
            }
        }
        .onChange(of: gameService.game.status) { status in
            print("🔄 Status changed to: \(status)")
            switch status {
            case .playing:
                // ← navigate to game
                navigateToGame = true
            case .lobby:
                // ← reset from new round — stay in waiting room
                navigateToGame = false
                isStarting = false
                errorMessage = nil
                print("🔄 Game reset — back to lobby")
            default:
                break
            }
        }
        .navigationDestination(isPresented: $navigateToGame) {
            OnlineGameView(
                gameId: gameId,
                gameService: gameService
            )
        }
    }
    
    private func startGame() async {
        isStarting = true
        errorMessage = nil
        
        print("🔄 Starting game with \(gameService.players.count) players")
        
        do {
            try await gameService.startGame(gameId: gameId)
            try await chatService.sendSystemMessage(
                gameId: gameId,
                text: "🎮 Game started! Find the impostor."
            )
            print("✅ Game started successfully")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Start failed: \(error)")
        }
        
        isStarting = false
    }
}
