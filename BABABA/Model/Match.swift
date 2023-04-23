//
//  Match.swift
//  BABABA
//
//  Created by Snow on 2023/01/27.
//

import Foundation
import FirebaseFirestoreSwift

// MARK: Game Model
struct Match: Identifiable,Codable,Equatable,Hashable {
    @DocumentID var id: String?
    var date: String
    var titleText: String
    var placeText: String
    var playStyleText: String
    var documentText: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
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
        case userName
        case userUID
        case userProfileURL
    }
}
