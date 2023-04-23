//
//  Intro.swift
//  BABABA
//
//  Created by Snow on 2023/02/07.
//

import SwiftUI

// MARK: Intro Model And Sample Intro's
struct Intro: Identifiable {
    var id: String = UUID().uuidString
    var imageName: String
    var title: String
    var text: String
}

var intros: [Intro] = [
    .init(imageName: "Friend", title: "Friend", text: "Join our basketball community.\nEnjoy the game together and make new basketball buddies!"),
    .init(imageName: "Train", title: "Train", text: "You can record your own game results.\nYou can also check the results of other players."),
    .init(imageName: "Match", title: "Match", text: "Of course,if you want to become a pro,you can also beat your opponents here."),
]

