//
//  Grid.swift
//  Memorize
//
//  Created by Vladimir Stepanchikov on 19.06.2021.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI

struct Grid<Item, ID, ItemView>: View where ID: Hashable,ItemView: View {
    private let items: [Item]
    private let id: KeyPath<Item, ID>
    private let viewForItem: (Item) -> ItemView
    
    init(_ items: [Item], id: KeyPath<Item, ID>, viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.id = id
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        GeometryReader { geometry in
            body(for: GridLayout(itemCount: items.count, in: geometry.size))
        }
    }
    
    private func body(for layout: GridLayout) -> some View {
        ForEach(items, id: id) { item in
            body(for: item, in: layout)
        }
    }
    private func body(for item: Item, in layout: GridLayout) -> some View {
        let index = items.firstIndex(where: { item[keyPath: id] == $0[keyPath: id] })
        return viewForItem(item)
            .frame(width: layout.itemSize.width, height: layout.itemSize.height)
            .position(layout.location(ofItemAt: index!))
    }
}

extension Grid where Item: Identifiable, ID == Item.ID {
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.init(items, id: \Item.id, viewForItem: viewForItem)
    }
}
