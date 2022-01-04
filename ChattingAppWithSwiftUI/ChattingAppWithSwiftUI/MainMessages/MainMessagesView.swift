//
//  MainMessageView.swift
//  ChattingAppWithSwiftUI
//
//  Created by Jinyung Yoon on 2021/12/14.
//

import SwiftUI
import SDWebImageSwiftUI


struct MainMessagesView: View {
    
    @State private var shouldShowLogOutOption = false
    @ObservedObject private var viewModel = MainMessagesViewModel()
    @State private var shouldShowNewMessageScreen = false
    @State private var chatUser: ChatUser?
    @State private var shouldNavigateToChatLogView = false
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    var body: some View {
        NavigationView {
            VStack {
                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(viewModel: chatLogViewModel)
                }
            }
            .overlay (
                newMessageButton
                , alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            WebImage(url: URL(string: viewModel.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width:50, height: 50)
                .clipped()
                .cornerRadius(25)
                .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                let email = viewModel.chatUser?.email.components(separatedBy: "@")
                Text(email?[0] ?? "")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button {
                shouldShowLogOutOption.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOption) {
            .init(title: Text("Settings"), message: Text("Waht do you want to do?"), buttons: [.destructive(Text("Sign Out"), action: {
                viewModel.handleSignOut()
            }), .cancel()])
        }
        .fullScreenCover(isPresented: $viewModel.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView {
                self.viewModel.isUserCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
                self.viewModel.fetchRecentMessages()
            }
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(viewModel.recentMessages) { message in
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == message.fromId ? message.toId : message.fromId
                        self.chatUser = .init(data: [
                            FirebaseConstants.uid : uid,
                            FirebaseConstants.email : message.email,
                            FirebaseConstants.profileImageUrl : message.profileImageUrl
                        ])
                        self.chatLogViewModel.chatUser = self.chatUser
                        self.chatLogViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: message.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width:60, height: 60)
                                .clipped()
                                .cornerRadius(30)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                            .stroke(Color(.label), lineWidth: 1))
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading) {
                                Text(message.username)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text(message.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text(message.timeAgo)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(.label))
                                if message.isRead == false {
                                    Text("New")
                                        .font(.system(size:12, weight: .semibold))
                                        .foregroundColor(Color.red)
                                }
                            }
                        }
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
                self.chatLogViewModel.chatUser = user
                self.chatLogViewModel.fetchMessages()
            }
        }
    }
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
    }
}
