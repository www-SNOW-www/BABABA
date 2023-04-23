//
//  Game.swift
//  BABABA
//
//  Created by Snow on 2023/01/14.
//

import SwiftUI
import FirebaseFirestoreSwift

// MARK: Game Model
struct Game: Identifiable,Codable,Equatable,Hashable {
    @DocumentID var id: String?
    var date:String
    var titleText: String
    var placeText: String
    var playStyleText: String
    var documentText: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var attendIDs: [String] = []
    // MARK: Basic User Info
    var userName: String
    var userUID: String
    var userProfileURL: URL
    
    enum Codingkeys: CodingKey {
        case id
        case date
        case titleText
        case placeText
        case playStyleText
        case documentText
        case imageURL
        case imageReferenceId
        case publishedDate
        case likedIDs
        case attendIDs
        case userName
        case userUID
        case userProfileURL
    }
}
