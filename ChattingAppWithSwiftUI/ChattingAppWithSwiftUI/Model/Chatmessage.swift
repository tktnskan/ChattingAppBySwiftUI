//
//  Chatmessage.swift
//  ChattingAppWithSwiftUI
//
//  Created by Jinyung Yoon on 2021/12/23.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
    var isRead: Bool
}
