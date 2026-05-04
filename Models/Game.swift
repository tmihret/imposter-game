//
//  Game.swift
//  imposterFinalProject
//
//  Created by admin on 4/26/26.
//


import FirebaseFirestore

struct Game: Codable, Identifiable {
    @DocumentID var id: String?
    var status: GameStatus
    var hostId: String
    var code: String
    var word: String
    var impostorWord: String
    var category: String
    var impostorId: String
    var eliminatedId: String
    var round: Int
    
    enum GameStatus: String, Codable {
        case lobby
        case playing
        case voting
        case results
        case ended
    }
    
    static let empty = Game(
        status: .lobby,
        hostId: "",
        code: "",
        word: "",
        impostorWord: "",
        category: "",
        impostorId: "",
        eliminatedId: "",
        round: 1
    )
}
