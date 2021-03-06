//
//  FirebaseManager.swift
//  ChattingAppWithSwiftUI
//
//  Created by Jinyung Yoon on 2021/12/14.
//

import Foundation
import Firebase

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}
