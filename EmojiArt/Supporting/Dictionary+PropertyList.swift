//
//  Dictionary+PropertyList.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 17.09.2021.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Foundation

extension Dictionary where Key == EmojiArtDocumentViewModel, Value == String {
    var asPropertyList: [String: String] {
        var uuidToName = [String: String]()
        for (key, value) in self {
            uuidToName[key.id.uuidString] = value
        }
        return uuidToName
    }

    init(fromPropertyList plist: Any?) {
        self.init()
        let uuidToName = plist as? [String: String] ?? [:]
        for uuid in uuidToName.keys {
            self[EmojiArtDocumentViewModel(id: UUID(uuidString: uuid))] = uuidToName[uuid]
        }
    }
}
