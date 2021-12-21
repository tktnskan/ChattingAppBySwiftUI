//
//  ChatLogView.swift
//  ChattingAppWithSwiftUI
//
//  Created by GJC03280 on 2021/12/17.
//

import SwiftUI

struct ChatLogView: View {
    
    static let emptyScrollToString = "Empty"
    let chatUser: ChatUser?
    @ObservedObject var viewModel: ChatLogViewModel
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.viewModel = ChatLogViewModel(chatUser: chatUser)
    }
    
    var body: some View {
        ZStack {
            messagesView
            Text(viewModel.errorMessage)
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        
        VStack {
            if #available(iOS 15.0, *) {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(viewModel.chatMessages) { message in
                                MessageView(message: message)
                            }
                            HStack {
                                Spacer()
                            }
                            .id(Self.emptyScrollToString)
                        }
                        .onReceive(viewModel.$count) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                            }
                        }
                    }
                }
                .background(Color(.init(white: 0.95, alpha: 1)))
                .safeAreaInset(edge: .bottom) {
                    chatBottomBar
                        .background(Color(.systemBackground).ignoresSafeArea())
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
//                TextEditor(text: $chatText)
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $viewModel.charText).opacity(viewModel.charText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            Button {
                viewModel.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)

        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: .init(data: ["uid":"AQ7xUDT3pvV6FiF0Gm4lnTIjoF52" ,"email":"JinyungYoon@gmail.com"]))
        }
//        MainMessagesView()
    }
}
