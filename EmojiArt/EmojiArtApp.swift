//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 04.09.2021.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let store = EmojiArtDocumentStore(
        directory: FileManager.default.urls(for: .documentDirectory,
                                               in: .userDomainMask).first!
    )

    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentChooser().environmentObject(store)
        }
    }
}
