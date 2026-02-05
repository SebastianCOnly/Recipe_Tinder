//
//  UserInfoView.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/27/26.
//

import SwiftUI

struct UserInfoView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(user.username)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    print("DEBUG: Show profile here..")
                } label: {
                    Image(systemName: "arrow.up.circle")
                        .fontWeight(.bold)
                        .imageScale(.large)
                    
                }
            }
            Text("Bold Authentic Flavors")
                .font(.subheadline)
                .lineLimit(2)
        }
        .foregroundStyle(.white)
        .padding()
        .background(
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    UserInfoView(user: MockData.users[1])
}
