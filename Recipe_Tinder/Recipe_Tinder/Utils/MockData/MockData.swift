//
//  MockData.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/28/26.
//

import Foundation

struct MockData {
    
    static let users: [User] = [
        .init(id: NSUUID().uuidString, username: "Mexican Food", profileImageURLS: ["mex_food", "mexFood2"]),
        
        .init(id: NSUUID().uuidString, username: "Italian Food", profileImageURLS: ["pasta", "pasta2"]),
        
        .init(id: NSUUID().uuidString, username: "American Food", profileImageURLS: ["amer1", "amer2"]),
        
        .init(id: NSUUID().uuidString, username: "Chinese Food", profileImageURLS: ["chin1", "chin2"]),
        
        .init(id: NSUUID().uuidString, username: "Indian Food", profileImageURLS: ["ind1", "ind2"]),
        
        .init(id: NSUUID().uuidString, username: "Mediterranean Food", profileImageURLS: ["med1", "med2"]),
        
        .init(id: NSUUID().uuidString, username: "Japanese Food", profileImageURLS: ["jap1", "jap2"]),
        
        .init(id: NSUUID().uuidString, username: "Korean Food", profileImageURLS: ["kor1", "kor2"]),
        
        .init(id: NSUUID().uuidString, username: "Greek Food", profileImageURLS: ["gre1", "gre2"]),
        
        .init(id: NSUUID().uuidString, username: "Filipino Food", profileImageURLS: ["fil1", "fil2"]),
        ]
}
