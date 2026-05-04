import FirebaseFirestore
import FirebaseAuth
import Foundation

class GameService: ObservableObject {
    private let db = Firestore.firestore()
    private var gameListener: ListenerRegistration?
    private var playersListener: ListenerRegistration?
    
    @Published var game: Game = .empty
    @Published var players: [Player] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Create Game
    func createGame(hostName: String) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw GameError.notAuthenticated
        }
        
        try await setDisplayName(hostName)
        
        let gameRef = db.collection("games").document()
        let code = generateCode()
        
        let newGame = Game(
            status: .lobby,
            hostId: uid,
            code: code,
            word: "",
            impostorWord: "",
            category: "",
            impostorId: "",
            eliminatedId: "",
            round: 1
        )
        
        try gameRef.setData(from: newGame)
        print("✅ Game created: \(gameRef.documentID)")
        
        try await addPlayer(
            gameId: gameRef.documentID,
            playerId: uid,
            name: hostName
        )
        
        return gameRef.documentID
    }
    
    //Join Game
    func joinGame(code: String, playerName: String) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw GameError.notAuthenticated
        }
        
        let snapshot = try await db.collection("games")
            .whereField("code", isEqualTo: code.uppercased())
            .whereField("status", isEqualTo: "lobby")
            .getDocuments()
        
        guard let gameDoc = snapshot.documents.first else {
            throw GameError.gameNotFound
        }
        
        try await setDisplayName(playerName)
        
        try await addPlayer(
            gameId: gameDoc.documentID,
            playerId: uid,
            name: playerName
        )
        
        print("✅ Joined game: \(gameDoc.documentID)")
        return gameDoc.documentID
    }
    
    // Add Player
    private func addPlayer(
        gameId: String,
        playerId: String,
        name: String
    ) async throws {
        let data: [String: Any] = [
            "name": name,
            "isAlive": true,
            "isImpostor": false,
            "vote": "",
            "word": ""
        ]
        
        try await db.collection("games")
            .document(gameId)
            .collection("players")
            .document(playerId)
            .setData(data)
        
        print("✅ Player added: \(name)")
    }
    
    // Start Game
    func startGame(gameId: String) async throws {
        guard players.count >= 2 else {
            throw GameError.notEnoughPlayers
        }
        
        let (category, word) = WordBank.randomWord()
        let impostorIndex = Int.random(in: 0..<players.count)
        let impostorId = players[impostorIndex].id ?? ""
        
        var impostorWord = word
        if let wordsInCategory = WordBank.categories[category] {
            let otherWords = wordsInCategory.filter { $0 != word }
            impostorWord = otherWords.randomElement() ?? word
        }
        
        // ← fixed: added missing comma
        try await db.collection("games")
            .document(gameId)
            .updateData([
                "status": "playing",
                "word": word,
                "impostorWord": impostorWord,   // ← comma fixed
                "category": category,
                "impostorId": impostorId,
                "eliminatedId": ""
            ])
        
        for player in players {
            guard let playerId = player.id else { continue }
            let playerWord = playerId == impostorId ? impostorWord : word
            try await db.collection("games")
                .document(gameId)
                .collection("players")
                .document(playerId)
                .updateData([
                    "isImpostor": playerId == impostorId,
                    "isAlive": true,
                    "vote": "",
                    "word": playerWord
                ])
        }
        
        print("✅ Game started")
    }
    
    // Move to Voting
    func moveToVoting(gameId: String) async throws {
        try await db.collection("games")
            .document(gameId)
            .updateData(["status": "voting"])
    }
    
    // Cast Vote
    func castVote(gameId: String, targetId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await db.collection("games")
            .document(gameId)
            .collection("players")
            .document(uid)
            .updateData(["vote": targetId])
        
        print("✅ Vote cast for: \(targetId)")
    }
    
    // Resolve Votes
    func resolveVotes(gameId: String) async throws {
        let votes = players
            .compactMap { $0.vote }
            .filter { !$0.isEmpty }
        
        let tally = Dictionary(grouping: votes, by: { $0 })
            .mapValues { $0.count }
        
        guard let eliminatedId = tally
            .max(by: { $0.value < $1.value })?.key
        else { return }
        
        let wasImpostor = eliminatedId == game.impostorId
        
        // Store eliminatedId and move to results
        // Don't mark isAlive: false permanently
        try await db.collection("games")
            .document(gameId)
            .updateData([
                "status": wasImpostor ? "ended" : "results",
                "eliminatedId": eliminatedId
            ])
        
        print("✅ Votes resolved — eliminated: \(eliminatedId)")
    }
    
    // Reset For New Round
    func resetForNewGame(gameId: String) async throws {
        // Reset game back to lobby
        try await db.collection("games")
            .document(gameId)
            .updateData([
                "status": "lobby",
                "word": "",
                "impostorWord": "",
                "category": "",
                "impostorId": "",
                "eliminatedId": ""
            ])
        
        // Reset ALL players
        for player in players {
            guard let playerId = player.id else { continue }
            try await db.collection("games")
                .document(gameId)
                .collection("players")
                .document(playerId)
                .updateData([
                    "isAlive": true,
                    "isImpostor": false,
                    "vote": "",
                    "word": ""
                ])
        }
        
        print("✅ Game reset for new round")
    }
    
    // Listen to Game
    func listenToGame(gameId: String) {
        gameListener = db.collection("games")
            .document(gameId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error {
                    print("❌ Game listener error: \(error)")
                    return
                }
                guard let doc = snapshot, doc.exists else { return }
                self?.game = (try? doc.data(as: Game.self)) ?? .empty
                print("🔄 Game updated: \(self?.game.status ?? .lobby)")
            }
        
        playersListener = db.collection("games")
            .document(gameId)
            .collection("players")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error {
                    print("❌ Players listener error: \(error)")
                    return
                }
                self?.players = snapshot?.documents.compactMap {
                    try? $0.data(as: Player.self)
                } ?? []
                print("🔄 Players updated: \(self?.players.count ?? 0)")
            }
    }
    
    // Stop Listening
    func stopListening() {
        gameListener?.remove()
        playersListener?.remove()
        gameListener = nil
        playersListener = nil
    }
    
    // Helpers
    private func setDisplayName(_ name: String) async throws {
        let changeRequest = Auth.auth().currentUser?
            .createProfileChangeRequest()
        changeRequest?.displayName = name
        try await changeRequest?.commitChanges()
    }
    
    private func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
    
    var isHost: Bool {
        game.hostId == Auth.auth().currentUser?.uid
    }
    
    var currentPlayer: Player? {
        players.first { $0.id == Auth.auth().currentUser?.uid }
    }
    
    var alivePlayers: [Player] {
        players.filter { $0.isAlive }
    }
    
    var allVotesCast: Bool {
        players.allSatisfy { $0.hasVoted }  // ← all players not just alive
    }
    
    var voteCounts: [String: Int] {
        Dictionary(
            grouping: players.compactMap { $0.vote },
            by: { $0 }
        ).mapValues { $0.count }
    }
    
    // Errors
    enum GameError: LocalizedError {
        case notAuthenticated
        case gameNotFound
        case notEnoughPlayers
        
        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "Not signed in — try restarting the app"
            case .gameNotFound:
                return "Game not found — check your code"
            case .notEnoughPlayers:
                return "Need at least 2 players to start"
            }
        }
    }
}
