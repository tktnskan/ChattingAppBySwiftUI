//
//  MainMessagesViewModel.swift
//  ChattingAppWithSwiftUI
//
//  Created by Jinyung Yoon on 2021/12/17.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import SwiftUI
import SDWebImageSwiftUI

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    @Published var recentMessages = [RecentMessage]()
    
    @Published var image: UIImage?
    private var firestoreListener: ListenerRegistration?
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func fetchCurrentUser() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user: ", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No Data found"
                return
            }
//            self.errorMessage = "Data: \(data.description)"
            self.chatUser = .init(data: data)
            FirebaseManager.shared.currentUser = self.chatUser
//            self.errorMessage = chatUser?.profileImageUrl
        }
    }
    
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            errorMessage = "Could not find firebase uid"
            return
        }
        
        firestoreListener?.remove()
        recentMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print("Failed to listen for recent messages: \(error)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    print(change.type.rawValue)
                    
                    let docId = change.document.documentID
                
                    if let index = self.recentMessages.firstIndex(where: { recentMessage in
                        return recentMessage.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do {
                        if let recentMessage = try change.document.data(as: RecentMessage.self) {
                            print(recentMessage)
                            self.recentMessages.insert(recentMessage, at: 0)
                        }
                    } catch {
                        print(error)
                    }
                })
            }
    }
    
    func changeProfile() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { (metaDatam, error) in
            if let error = error {
                self.errorMessage = "Failed to push image to Storage: \(error)"
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    self.errorMessage = "Failed to retrieve downloadURL: \(error)"
                    return
                }
                
                self.errorMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).updateData(["profileImageUrl": imageProfileUrl.absoluteString]) { error in
                if let error = error {
                    self.errorMessage = "Failed to update ProfileImage : \(error)"
                }
                self.fetchCurrentUser()
            }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        chatUser = nil
    }
}
