//
//  MainViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

import Foundation

final class PlaylistGroupsViewModel {
        
    var onStateChange: ((PlaylistGroupsViewState) -> Void)?
    
    private var state: PlaylistGroupsViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    private var items: [Item] = []
    
    func loadPlaylistGroups() {
        state = .loading
        
        let item1: Item = .item(PlaylistGroupItem(id: UUID(), title: "Jungle"))
        let item2: Item = .item(PlaylistGroupItem(id: UUID(), title: "Chill & Focus"))
        let item3: Item = .item(PlaylistGroupItem(id: UUID(), title: "Piano"))
        let item4: Item = .item(PlaylistGroupItem(id: UUID(), title: "Fall '25"))
        let item5: Item = Item.add
        
        items = [item1, item2, item3, item4, item5]
        state = .loaded(items)
    }
}

// MARK: Types

extension PlaylistGroupsViewModel {
    
    enum Section: Hashable { case main }
    
    enum Item: Hashable {
        case item(PlaylistGroupItem)
        case add
    }
    
    struct PlaylistGroupItem: Hashable {
        var id: UUID
        var title: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func ==(lhs: PlaylistGroupItem, rhs: PlaylistGroupItem) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum PlaylistGroupsViewState {
        case idle
        case loading
        case loaded([Item])
    }
}
