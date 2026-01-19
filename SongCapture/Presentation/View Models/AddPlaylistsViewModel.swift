//
//  AddPlaylistsViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/12/26.
//

import Foundation

final class AddPlaylistsViewModel {
    
    private let service: Service
    private let repository: Repository
    private let selectionStore: PlaylistSelectionStore
    
    private var state: ViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((ViewState) -> Void)?
    
    private var fetchPlaylistsTask: Task<Void, Never>?
    
    init(service: Service, repository: Repository, selectionStore: PlaylistSelectionStore) {
        self.service = service
        self.repository = repository
        self.selectionStore = selectionStore
    }
    
    func fetchPlaylists() {
        state = .loading
        
        fetchPlaylistsTask?.cancel()
        
        fetchPlaylistsTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let playlists = try await self.repository.fetchPlaylists(from: service)
                print("playlists: \(playlists)")
                await MainActor.run {
                    self.state = .loaded(self.makeRenderModel(from: playlists))
                }
            } catch {
                // TODO: Handle error
            }
        }
    }
    
    func toggleSelection(playlistID: PlaylistID) {
        // TODO: call
        selectionStore.toggle(playlistID)
    }
    
    deinit {
        fetchPlaylistsTask?.cancel()
    }
}

private extension AddPlaylistsViewModel {
    func makeRenderModel(from playlists: [Playlist]) -> RenderModel {
        print("JTJ: Making Render Model")
        // Make the row ID the playlist's unique ID
        let ids = playlists.map(\.id)
        
        // Create dictionary mapping ids to cell presentation data
        let rowsByID: [PlaylistID: PlaylistRowVM] = playlists.reduce(into: [:]) { res, playlist in
            res[playlist.id] = PlaylistRowVM(
                id: playlist.id,
                title: playlist.name,
                subtitle: playlist.service.title,
                artwork: playlist.artwork,
                selected: false
            )
        }
        return RenderModel(items: ids.map { Item.playlist($0) }, rowsByID: rowsByID)
    }
    
    func handleSelection(for playlistID: PlaylistID) {
        // TODO: Handle selection
    }
}

extension AddPlaylistsViewModel {
    
    enum ViewState {
        case idle
        case loading
        case loaded(RenderModel)
        case error
    }
    
    struct RenderModel: Equatable {
        /// The exact order of rows in the table (diffable identity only)
        let items: [Item]

        /// Presentation data for playlist rows, keyed by stable identity
        let rowsByID: [PlaylistID: PlaylistRowVM]
        
        /// Using this equality check in VC to only apply snapshot changes when new RenderModel has a different
        /// Items array. Presentation changes like row selection will not require a new snapshot applied.
        static func ==(lhs: RenderModel, rhs: RenderModel) -> Bool {
            lhs.items == rhs.items
        }
    }
    
    enum Section: Hashable {
        case main
    }
    
    enum Item: Hashable {
        case playlist(PlaylistID)
    }
    
    struct PlaylistRowVM {
        let id: PlaylistID
        let title: String
        let subtitle: String
        let artwork: PlaylistArtwork
        let selected: Bool
    }
}
