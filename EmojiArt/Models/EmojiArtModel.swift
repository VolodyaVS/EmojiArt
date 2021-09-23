//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 04.09.2021.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Foundation

struct EmojiArtModel: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()

    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int

        fileprivate init (text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }

    var json: Data? {
        return try? JSONEncoder().encode(self)
    }

    private var uniqueEmojiId = 0

    init() { }

    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArtModel.self, from: json!) {
            self = newEmojiArt
        } else {
            return nil
        }
    }

    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
