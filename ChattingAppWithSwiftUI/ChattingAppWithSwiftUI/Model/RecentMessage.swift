//
//  RecentMessage.swift
//  ChattingAppWithSwiftUI
//
//  Created by Jinyung Yoon on 2021/12/23.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    let text, email: String
    let fromId, toId, profileImageUrl: String
    let timestamp: Date
    var isRead: Bool
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let today = Calendar.current.dateComponents([.day], from: Date())
        let messageDay = Calendar.current.dateComponents([.day], from: timestamp)
        if today == messageDay {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm a"
            return formatter.string(from: timestamp)
        } else {
            guard let currentDay = today.day, let pastDay = messageDay.day else { return "none"}
            if currentDay - pastDay == 1 {
                return "yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd"
                return formatter.string(from: timestamp)
            }
        }
    }
}
