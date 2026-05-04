//
//  ChatService.swift
//  imposterFinalProject
//
//  Created by admin on 5/3/26.
//


import FirebaseFirestore
import FirebaseAuth
import Foundation

class ChatService: ObservableObject {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = true
    
    //Listen
    func startListening(gameId: String) {
        isLoading = true
        
        listener = db.collection("games")
            .document(gameId)
            .collection("chat")
            .order(by: "timestamp")
            .limit(toLast: 100)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                
                self.isLoading = false
                
                if let error {
                    print("❌ Chat listener error: \(error)")
                    return
                }
                
                guard let changes = snapshot?.documentChanges
                else { return }
                
                for change in changes where change.type == .added {
                    if let msg = try? change.document
                        .data(as: ChatMessage.self) {
                        // Avoid duplicates
                        if !self.messages.contains(
                            where: { $0.id == msg.id }
                        ) {
                            self.messages.append(msg)
                            print("💬 New message: \(msg.text)")
                        }
                    }
                }
            }
    }
    
    //Send User Message
    func sendMessage(gameId: String, text: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        let trimmed = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmed.isEmpty else { return }
        
        let msg = ChatMessage(
            senderId: user.uid,
            senderName: user.displayName ?? "Unknown",
            text: trimmed,
            timestamp: Timestamp(),
            type: .user
        )
        
        try db.collection("games")
            .document(gameId)
            .collection("chat")
            .addDocument(from: msg)
        
        print("✅ Message sent")
    }
    
    // Send System Message
    // Called automatically by GameService
    // for game events like eliminations
    func sendSystemMessage(
        gameId: String,
        text: String
    ) async throws {
        let msg = ChatMessage(
            senderId: "system",
            senderName: "Game",
            text: text,
            timestamp: Timestamp(),
            type: .system
        )
        
        try db.collection("games")
            .document(gameId)
            .collection("chat")
            .addDocument(from: msg)
        
        print("✅ System message sent: \(text)")
    }
    
    // Stop Listening
    func stopListening() {
        listener?.remove()
        listener = nil
        messages = []
        isLoading = true
    }
}
