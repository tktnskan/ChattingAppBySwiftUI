//
//  MainMessagesViewModel.swift
//  ChattingAppWithSwiftUI
//
//  Created by GJC03280 on 2021/12/17.
//

import Foundation

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
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
            
//            self.errorMessage = chatUser?.profileImageUrl
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
