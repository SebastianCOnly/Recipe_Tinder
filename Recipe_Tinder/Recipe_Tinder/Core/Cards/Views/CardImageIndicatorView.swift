//
//  CardImageIndicatorView.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/28/26.
//

import SwiftUI

struct CardImageIndicatorView: View {
    let currentImageIndex: Int
    let imageCount: Int
    
    var body: some View {
        HStack{
            ForEach(0 ..< imageCount, id: \.self) { index in
                Capsule()
                    .foregroundStyle(index == currentImageIndex ? .white : .gray)
                    .frame(width: 100, height: 4)
                    .padding(.top, 8)
            }
        }
    }
}

private extension CardImageIndicatorView {
    var imageIndicatorWidth: CGFloat {
        return SizeConstants.cardWidth / CGFloat(imageCount) - 28
    }
}


#Preview {
    CardImageIndicatorView(currentImageIndex: 1, imageCount: 3)
        .preferredColorScheme(.dark)
}
