//
//  PlaylistsAndGroupsViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

import Foundation

final class PlaylistsAndGroupsViewModel {
    
    private let repository: Repository
        
    var onStateChange: ((PlaylistsAndGroupsViewState) -> Void)?
    
    private var state: PlaylistsAndGroupsViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    private var items: [Item] = []
    
    func loadPlaylistsAndGroups() {
        state = .loading
        
        let item1: Item = .playlist(Playlist(id: PlaylistID(UUID().uuidString), name: "Jungle", artwork: .none, service: .appleMusic))
        let item2: Item = .playlist(Playlist(id: PlaylistID(UUID().uuidString), name: "Chill & Focus", artwork: .none, service: .appleMusic))
        let item3: Item = .playlist(Playlist(id: PlaylistID(UUID().uuidString), name: "Piano", artwork: .none, service: .appleMusic))
        let addPlaylist: Item = .addPlaylist
        
        let item4: Item = .group(PlaylistGroupItem(id: UUID(), title: "Jungle"))
        let item5: Item = .group(PlaylistGroupItem(id: UUID(), title: "Chill & Focus"))
        let item6: Item = .group(PlaylistGroupItem(id: UUID(), title: "Piano"))
        let item7: Item = .group(PlaylistGroupItem(id: UUID(), title: "Fall '25"))
        let addGroup: Item = Item.addGroup
        
        
        let playlists = [item1, item2, item3, addPlaylist]
        let groups = [item4, item5, item6, item7, addGroup]
        state = .loaded(playlists: playlists, groups: groups)
    }
}

// TODO: Maybe follow similar pattern to NewEditGroupViewModel and make use of a makeRenderModel() function
private extension PlaylistsAndGroupsViewModel {
    func makeRenderModel() -> RenderModel {
        return RenderModel(section: [], itemsBySection: [:])
    }
}

// MARK: Types

extension PlaylistsAndGroupsViewModel {
    
    enum PlaylistsAndGroupsViewState {
        case idle
        case loading
        case loaded(playlists: [Item], groups: [Item])
    }
    
    struct RenderModel {
        let section: [Section]
        let itemsBySection: [Section: [Item]]
    }
    
    enum Section: Hashable {
        case playlists
        case groups
    }
    
    enum Item: Hashable {
        case playlist(Playlist)
        case group(PlaylistGroupItem)
        case addPlaylist
        case addGroup
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
}

