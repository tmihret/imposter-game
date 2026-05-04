//
//  ChatMessage.swift
//  imposterFinalProject
//
//  Created by admin on 4/26/26.
//


import FirebaseFirestoreimport FirebaseAuthstruct ChatMessage: Codable, Identifiable {    @DocumentID var id: String?    var senderId: String    var senderName: String    var text: String    var timestamp: Timestamp    var type: MessageType        enum MessageType: String, Codable {        case user        case system    }        var isCurrentUser: Bool {        senderId == Auth.auth().currentUser?.uid    }}