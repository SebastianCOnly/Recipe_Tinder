//
//  SwipeActionIndicatorView.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/27/26.
//

import SwiftUI

struct SwipeActionIndicatorView: View {
    @Binding var xOffset: CGFloat
    
    
    var body: some View {
        HStack {
            Text("LIKE")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.green)
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.green, lineWidth: 2)
                        .frame(width: 100, height: 48)
                }
                .rotationEffect(.degrees(-45))
                .opacity(Double (xOffset / SizeConstants.screenCutoff))
            
            Spacer()
            
            Text("NOPE")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.red)
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.red, lineWidth: 2)
                        .frame(width: 100, height: 48)
                }
                .rotationEffect(.degrees(45))
                .opacity(Double (xOffset / SizeConstants.screenCutoff) * -1)
        }
        .padding(40)
    }
}

#Preview {
    SwipeActionIndicatorView(xOffset: .constant(20))
}
