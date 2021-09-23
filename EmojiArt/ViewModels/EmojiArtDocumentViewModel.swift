//
//  EmojiArtDocumentViewModel.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 04.09.2021.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocumentViewModel: ObservableObject, Hashable, Identifiable {
    static let palette = "⭐️🌧🍎🌏🥐⚽️"

    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }

    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }

    let id: UUID
    var url: URL? { didSet { save(emojiArt) } }

    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero

    @Published private var emojiArt: EmojiArtModel
    @Published private(set) var backgroundImage: UIImage?

    private var autosaveCancellable: AnyCancellable?
    private var fetchImageCancellable: AnyCancellable?

    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultsKey = "EmojiArtDocument.\(self.id.uuidString)"

        emojiArt = EmojiArtModel(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArtModel()
        autosaveCancellable = $emojiArt.sink { emojiArt in
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
    }

    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.emojiArt = EmojiArtModel(json: try? Data(contentsOf: url)) ?? EmojiArtModel()
        fetchBackgroundImageData()
        autosaveCancellable = $emojiArt.sink(receiveValue: { emojiArt in
            self.save(emojiArt)
        })
    }

    // MARK: - Intent(s)
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }

    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: EmojiArtDocumentViewModel, rhs: EmojiArtDocumentViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, urlResponse in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \EmojiArtDocumentViewModel.backgroundImage, on: self)
        }
    }

    private func save(_ emojiArt: EmojiArtModel) {
        if url != nil {
            try? emojiArt.json?.write(to: url!)
        }
    }
}

extension EmojiArtModel.Emoji {
    var fontSize: CGFloat { CGFloat(size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
