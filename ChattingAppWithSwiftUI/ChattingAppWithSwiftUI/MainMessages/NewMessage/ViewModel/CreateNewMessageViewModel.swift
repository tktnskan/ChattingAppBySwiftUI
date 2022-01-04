//
//  CreateNewMessageViewModel.swift
//  ChattingAppWithSwiftUI
//
//  Created by Jinyung Yoon on 2021/12/17.
//

import Foundation

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUser()
    }
    
    private func fetchAllUser() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                self.users = [ChatUser]()
                documentSnapshot?.documents.forEach({ snapshot in
                    let user = ChatUser(data: snapshot.data())
//                    if user.uid != FirebaseManager.shared.auth.currentUser.uid {
                        self.users.append(user)
//                    }
                })
                
//                self.errorMessage = "Fetched users successfully"
            }
    }
}
