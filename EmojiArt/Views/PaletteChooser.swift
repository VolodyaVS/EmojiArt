//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 14.09.2021.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocumentViewModel
    @Binding var choosenPalette: String
    
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    choosenPalette = document.palette(after: choosenPalette)
                },
                onDecrement: {
                    choosenPalette = document.palette(before: choosenPalette)
                },
                label: {
                    EmptyView()
                }
            )
            Text(document.paletteNames[choosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor) {
                    PaletteEditor(choosenPalette: $choosenPalette, isShowing: $showPaletteEditor)
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocumentViewModel(), choosenPalette: .constant(""))
    }
}
