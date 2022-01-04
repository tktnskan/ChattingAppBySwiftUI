//
//  CreateNewMessageView.swift
//  ChattingAppWithSwiftUI
//
//  Created by Jinyung Yoon on 2021/12/17.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreateNewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView {
                Text(viewModel.errorMessage)
                ForEach(viewModel.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(25)
                                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label), lineWidth: 2))
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }
                        .padding(.horizontal)
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("NewMessage")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
//        CreateNewMessageView { chatUser in
            
//        }
        MainMessagesView()
    }
}
