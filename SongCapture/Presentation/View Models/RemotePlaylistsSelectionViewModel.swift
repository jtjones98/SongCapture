//
//  RemotePlaylistsSelectionViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/12/26.
//

import Combine
import Foundation
import MusicKit

final class RemotePlaylistsSelectionViewModel {
    
    private let service: Service
    private let loadRemoteUseCase: LoadRemoteUseCase
    
    private var draftSelections: Set<PlaylistID> = []
    private var playlistsByID: [PlaylistID: Playlist] = [:]
    
    @Published private(set) var state: ViewState = .idle

    var onSave: ((Set<PlaylistID>, [PlaylistID: Playlist]) -> Void)?
    
    private var fetchPlaylistsTask: Task<Void, Never>?
    
    init(service: Service, selections: Set<PlaylistID>, loadRemoteUseCase: LoadRemoteUseCase) {
        self.service = service
        self.loadRemoteUseCase = loadRemoteUseCase
        self.draftSelections = selections
    }
    
    func fetchPlaylists() {
        state = .loading
        
        fetchPlaylistsTask?.cancel()
        
        fetchPlaylistsTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let playlists = try await loadRemoteUseCase.fetchPlaylists(from: service)
                self.playlistsByID = playlists.reduce(into: [:]) { $0[$1.id] = $1 }
                await MainActor.run {
                    self.state = .loaded(self.makeRenderModel(from: playlists))
                }
            } catch {
                // TODO: Handle loading remote playlists error
            }
        }
    }
    
    func setSelection(_ selection: Bool, for id: PlaylistID) {
        if selection {
            draftSelections.insert(id)
        } else {
            draftSelections.remove(id)
        }
    }
        
    func isSelected(_ id: PlaylistID) -> Bool {
        draftSelections.contains(id)
    }
    
    func saveSelections() {
        let localPlaylistsByID = playlistsByID.filter { draftSelections.contains($0.key) }
        onSave?(draftSelections, localPlaylistsByID)
    }
    
    deinit {
        fetchPlaylistsTask?.cancel()
    }
}

private extension RemotePlaylistsSelectionViewModel {
    func makeRenderModel(from playlists: [Playlist]) -> RenderModel {
        // Make the row ID the playlist's unique ID
        let ids = playlists.map(\.id)
        
        // Create dictionary mapping ids to cell presentation data
        let rowsByID: [PlaylistID: PlaylistRowVM] = playlists.reduce(into: [:]) { res, playlist in
            res[playlist.id] = PlaylistRowVM(
                id: playlist.id,
                title: playlist.name,
                subtitle: playlist.id.service.title,
                artwork: playlist.artwork,
                selected: draftSelections.contains(playlist.id) // May be unneccessary, future proofing in case we end up calling to makeRenderModel multiple times while on this screen. Right now, its called once when we first loads.
            )
        }
        return RenderModel(items: ids.map { Item.playlist($0) }, rowsByID: rowsByID)
    }
}

extension RemotePlaylistsSelectionViewModel {
    
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
    
    struct PlaylistRowVM {
        let id: PlaylistID
        let title: String
        let subtitle: String
        let artwork: PlaylistArtwork
        let selected: Bool
    }
    
    enum Section: Hashable {
        case main
    }
    
    enum Item: Hashable {
        case playlist(PlaylistID)
    }
}
