//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 13.09.2021.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?

    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
