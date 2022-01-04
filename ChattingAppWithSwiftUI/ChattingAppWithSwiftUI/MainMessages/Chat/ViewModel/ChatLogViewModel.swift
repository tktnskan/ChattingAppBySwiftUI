//
//  ChatLogViewModel.swift
//  ChattingAppWithSwiftUI
//
//  Created by Jinyung Yoon on 2021/12/21.
//

import Foundation
import Firebase

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var count = 0
    @Published var chatMessages = [ChatMessage]()
    
    var firestoreListener: ListenerRegistration?
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.checkRecentMessage()
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            if let chatMessage = try change.document.data(as: ChatMessage.self) {
                                self.chatMessages.append(chatMessage)
                                print("Appending chatMessage in ChatLogView: \(Date())")
                            }
                        } catch {
                            print("Failed to decode message: \(error)")
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let messagedata = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date(), isRead: true)
        
        self.chatText = ""
        
        try? document.setData(from: messagedata) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage(chatText: messagedata.text)
            self.count += 1
        }
        
        if fromId != toId {
            let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
                .document(toId)
                .collection(fromId)
                .document()
            
            try? recipientMessageDocument.setData(from: messagedata) { error in
                if let error = error {
                    print(error)
                    self.errorMessage = "Failed to save message into Firestore: \(error)"
                    return
                }
                
                print("Recipient saved message as well")
            }
        }
    }
    
    func checkRecentMessage() {
        guard let toId = self.chatUser?.uid else { return }
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(currentUser.uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
    
        document.updateData(["isRead":true]) { error in
            if let error = error {
                self.errorMessage = "Failed to update message into Firestore: \(error)"
            }
        }
    }
    
    private func persistRecentMessage(chatText: String) {
        guard let chatUser = chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email,
            "isRead" : true
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        if uid != toId {
            guard let currentUser = FirebaseManager.shared.currentUser else { return }
            let recipientRecentMessageDictionary = [
                FirebaseConstants.timestamp: Timestamp(),
                FirebaseConstants.text: chatText,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
                FirebaseConstants.email: currentUser.email,
                "isRead" : false
            ] as [String : Any]
            
            FirebaseManager.shared.firestore
                .collection(FirebaseConstants.recentMessages)
                .document(toId)
                .collection(FirebaseConstants.messages)
                .document(currentUser.uid)
                .setData(recipientRecentMessageDictionary) { error in
                    if let error = error {
                        print("Failed to save recipient recent message: \(error)")
                        return
                    }
                }
        }
    }
}
