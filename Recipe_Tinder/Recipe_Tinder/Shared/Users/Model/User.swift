//
//  User.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/28/26.
//

import Foundation

struct User: Identifiable, Hashable {
    let id: String
    let username: String
    var age: Int?
    var profileImageURLS: [String]
}
