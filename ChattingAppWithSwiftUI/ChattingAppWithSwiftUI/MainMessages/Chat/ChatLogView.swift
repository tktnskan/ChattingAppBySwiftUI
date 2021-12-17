//
//  ChatLogView.swift
//  ChattingAppWithSwiftUI
//
//  Created by GJC03280 on 2021/12/17.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    var body: some View {
        ScrollView {
            ForEach(0..<10) { num in
                Text("FAKE Message For Now")
            }
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(chatUser: nil)
    }
}
