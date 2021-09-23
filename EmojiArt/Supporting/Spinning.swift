//
//  Spinning.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 14.09.2021.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI

struct Spinning: ViewModifier {
    @State var isVisible = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisible ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear { isVisible = true }
    }
}

extension View {
    func spinning() -> some View {
        modifier(Spinning())
    }
}
