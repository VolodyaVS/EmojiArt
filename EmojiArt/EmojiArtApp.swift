//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 04.09.2021.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let store = EmojiArtDocumentStore(named: "Emoji Art")

    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentChooser().environmentObject(store)
        }
    }
}
