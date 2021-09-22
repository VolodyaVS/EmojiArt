//
//  EmojiArtDocumentStore.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 5/6/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocumentStore: ObservableObject {
    let name: String
    var documents: [EmojiArtDocumentViewModel] {
        documentNames.keys.sorted { documentNames[$0]! < documentNames[$1]! }
    }

    @Published private var documentNames = [EmojiArtDocumentViewModel: String]()
    private var autosave: AnyCancellable?

    init(named name: String = "Emoji Art") {
        self.name = name
        let defaultsKey = "EmojiArtDocumentStore.\(name)"
        documentNames = Dictionary(fromPropertyList: UserDefaults.standard.object(forKey: defaultsKey))
        autosave = $documentNames.sink { names in
            UserDefaults.standard.set(names.asPropertyList, forKey: defaultsKey)
        }
    }

    func name(for document: EmojiArtDocumentViewModel) -> String {
        if documentNames[document] == nil {
            documentNames[document] = "Untitled"
        }
        return documentNames[document]!
    }

    func setName(_ name: String, for document: EmojiArtDocumentViewModel) {
        documentNames[document] = name
    }

    func addDocument(named name: String = "Untitled") {
        documentNames[EmojiArtDocumentViewModel()] = name
    }

    func removeDocument(_ document: EmojiArtDocumentViewModel) {
        documentNames[document] = nil
    }
}
