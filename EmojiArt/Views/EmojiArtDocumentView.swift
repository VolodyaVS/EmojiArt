//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Vladimir Stepanchikov on 04.09.2021.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocumentViewModel

    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    private let defaultEmojiSize: CGFloat = 40

    @GestureState private var gestureZoomScale: CGFloat = 1.0
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * gestureZoomScale
    }

    @GestureState private var gesturePanOffset: CGSize = .zero
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }

    @State private var choosenPalette = ""
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false

    init(document: EmojiArtDocumentViewModel) {
        self.document = document
        _choosenPalette = State(wrappedValue: document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, choosenPalette: $choosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(choosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
            }
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                    )
                        .gesture(doubleTapToZoom(in: geometry.size))
                    if isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(panGesture())
                .gesture(zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(document.$backgroundImage) { image in
                    zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2,
                                       y: location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x - panOffset.width,
                                       y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale,
                                       y: location.y / zoomScale)
                    return drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != document.backgroundURL {
                        confirmBackgroundPaste = true
                    } else {
                        explainBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                        .alert(isPresented: $explainBackgroundPaste) {
                            Alert(
                                title: Text("Paste Background"),
                                message: Text("Copy the URL of a image to the clip board and touch this button to make it the background of your document."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                }))
            }
            .zIndex(-1)
        }
        .alert(isPresented: $confirmBackgroundPaste) {
            Alert(
                title: Text("Paste Background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?"),
                primaryButton: .default(Text("OK")) {
                    document.backgroundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.backgroundURL = url
        }
        if !found {
            found = providers.loadFirstObject(ofType: String.self) { string in
                document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }

    private func position(for emoji: EmojiArtModel.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale,
                           y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2,
                           y: location.y + size.height / 2)
        location = CGPoint(x: location.x + panOffset.width,
                           y: location.y + panOffset.height)
        return location
    }

    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }

    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.linear) {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                document.steadyStateZoomScale *= finalGestureScale
            }
    }

    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                document.steadyStatePanOffset = document.steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
}
