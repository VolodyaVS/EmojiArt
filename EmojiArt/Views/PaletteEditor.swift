//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 16.09.2021.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var choosenPalette: String
    @Binding var isShowing: Bool
    @EnvironmentObject var document: EmojiArtDocumentViewModel

    var height: CGFloat {
        CGFloat((choosenPalette.count - 1) / 6) * 70 + 70
    }
    let fontSize: CGFloat = 40
    
    @State private var paletteName = ""
    @State private var emojisToAdd = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: { isShowing = false }, label: {
                        Text("Done").padding()
                    })
                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            document.renamePalette(choosenPalette, to: paletteName)
                        }
                    })
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            choosenPalette = document.addEmoji(emojisToAdd, toPalette: choosenPalette)
                            document.renamePalette(choosenPalette, to: paletteName)
                            emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")) {
                    Grid(choosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: fontSize))
                            .onTapGesture {
                                choosenPalette = document.removeEmoji(emoji, fromPalette: choosenPalette)
                            }
                    }
                    .frame(height: height)
                }
            }
        }
        .onAppear {
            paletteName = document.paletteNames[choosenPalette] ?? ""
        }
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(choosenPalette: .constant("Faces"), isShowing: .constant(true))
    }
}
