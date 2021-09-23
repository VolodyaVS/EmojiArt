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
    private var directory: URL?

    init(named name: String = "Emoji Art") {
        self.name = name
        let defaultsKey = "EmojiArtDocumentStore.\(name)"
        documentNames = Dictionary(fromPropertyList: UserDefaults.standard.object(forKey: defaultsKey))
        autosave = $documentNames.sink { names in
            UserDefaults.standard.set(names.asPropertyList, forKey: defaultsKey)
        }
    }

    init(directory: URL) {
        self.name = directory.lastPathComponent
        self.directory = directory
        do {
            let documents = try FileManager.default.contentsOfDirectory(atPath: directory.path)
            for document in documents {
                let emojiArtDocument = EmojiArtDocumentViewModel(url: directory.appendingPathComponent(document))
                self.documentNames[emojiArtDocument] = document
            }
        } catch {
            print("EmojiArtDocumentStore couldn't create from directory: \(directory): \(error.localizedDescription)")
        }
    }

    func name(for document: EmojiArtDocumentViewModel) -> String {
        if documentNames[document] == nil {
            documentNames[document] = "Untitled"
        }
        return documentNames[document]!
    }

    func setName(_ name: String, for document: EmojiArtDocumentViewModel) {
        if let url = directory?.appendingPathComponent(name) {
            if !documentNames.values.contains(name) {
                removeDocument(document)
                document.url = url
                documentNames[document] = name
            }
        } else {
            documentNames[document] = name
        }
    }

    func addDocument(named name: String = "Untitled") {
        let uniqueName = name.uniqued(withRespectTo: documentNames.values)
        let document: EmojiArtDocumentViewModel

        if let url = directory?.appendingPathComponent(uniqueName) {
            document = EmojiArtDocumentViewModel(url: url)
        } else {
            document = EmojiArtDocumentViewModel()
        }
        documentNames[document] = uniqueName
    }

    func removeDocument(_ document: EmojiArtDocumentViewModel) {
        if let name = documentNames[document], let url = directory?.appendingPathComponent(name) {
            try? FileManager.default.removeItem(at: url)
        }
        documentNames[document] = nil
    }
}
