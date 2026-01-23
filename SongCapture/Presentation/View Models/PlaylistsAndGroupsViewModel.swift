//
//  PlaylistsAndGroupsViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

import Combine
import Foundation

final class PlaylistsAndGroupsViewModel {
    
    private let loadLibraryUseCase: LoadLibraryUseCase
    private var loadPlaylistsAndGroupsTask: Task<Void, Never>?
    @Published private(set) var state: PlaylistsAndGroupsViewState = .idle
    
    init(loadLibraryUseCase: LoadLibraryUseCase) {
        self.loadLibraryUseCase = loadLibraryUseCase
    }
    
    private var items: [Item] = []
    
    func loadPlaylistsAndGroups() {
        state = .loading

        loadPlaylistsAndGroupsTask?.cancel()

        loadPlaylistsAndGroupsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let (playlists, groups): ([Playlist], [PlaylistGroup]) = try await loadLibraryUseCase.fetchPlaylistsAndGroups()
                await MainActor.run {
                    let render = self.makeRenderModel(playlists: playlists, groups: groups)
                    self.state = .loaded(render)
                }
            } catch {
                // TODO: Handle load playlists and groups error
                await MainActor.run {
                    self.state = .idle
                }
            }
        }
    }
    
    deinit {
        loadPlaylistsAndGroupsTask?.cancel()
    }
}

// TODO: Maybe follow similar pattern to GroupEditorViewModel and make use of a makeRenderModel() function
private extension PlaylistsAndGroupsViewModel {
    func makeRenderModel(playlists: [Playlist], groups: [PlaylistGroup]) -> RenderModel {
        var sections: [Section] = []
        var itemsBySection: [Section: [Item]] = [:]
        
        sections.append(.playlists)
        if (!playlists.isEmpty) {
            for playlist in playlists {
                itemsBySection[.playlists, default: []].append(Item.playlist(playlist))
            }
        }
        
        sections.append(.groups)
        if (!groups.isEmpty) {
            for group in groups {
                itemsBySection[.groups, default: []].append(Item.group(group))
            }
        }
        
        itemsBySection[.playlists, default: []].append(Item.addPlaylist)
        itemsBySection[.groups, default: []].append(Item.addGroup)
        
        return RenderModel(sections: sections, itemsBySection: itemsBySection)
    }
}

// MARK: Types

extension PlaylistsAndGroupsViewModel {
    
    enum PlaylistsAndGroupsViewState {
        case idle
        case loading
        case loaded(RenderModel)
        // TODO: Error state
    }
    
    struct RenderModel {
        let sections: [Section]
        let itemsBySection: [Section: [Item]]
    }
    
    enum Section: Hashable {
        case playlists
        case groups
    }
    
    // TODO: Consider following similar pattern to RemotePlaylistsSelectionViewModel
    // make the diffable item hold just identity. Presentation data in a row view model
    enum Item: Hashable {
        case playlist(Playlist)
        case group(PlaylistGroup)
        case addPlaylist
        case addGroup
    }
}

