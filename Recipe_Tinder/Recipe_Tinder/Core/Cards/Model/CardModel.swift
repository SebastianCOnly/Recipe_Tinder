//
//  CardModel.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/28/26.
//

import Foundation

struct CardModel {
    let user: User
}

extension CardModel: Identifiable, Hashable {
    var id: String {
        return user.id
    }
}
