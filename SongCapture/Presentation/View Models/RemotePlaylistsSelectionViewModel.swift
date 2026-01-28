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
    
    private var initialLoadTask: Task<Void, Never>?
    private var paginationTask: Task<Void, Never>?
    private var canLoadMore = true
    private var isPageLoading = false
    
    init(service: Service, selections: Set<PlaylistID>, loadRemoteUseCase: LoadRemoteUseCase) {
        self.service = service
        self.loadRemoteUseCase = loadRemoteUseCase
        self.draftSelections = selections
    }
    
    func fetchFirstPage() {
        state = .loading
        isPageLoading = true
        
        initialLoadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.isPageLoading = false }
            
            await loadRemoteUseCase.reset(service: service)
            
            do {
                try await loadRemoteUseCase.loadMore(service: service)
                let snapshot = await loadRemoteUseCase.currentSnapshot(service: service)
                self.canLoadMore = snapshot.canLoadMore
                self.playlistsByID = snapshot.byID
                await MainActor.run {
                    self.state = .loaded(self.makeRenderModel(orderedIDs: snapshot.orderedIDs, playlistsByID: self.playlistsByID))
                }
            } catch {
                await MainActor.run {
                    self.state = .error
                }
            }
        }
    }
        
    func fetchNextPageIfNeeded(currentIndex: Int, threshold: Int = 10) {
        guard canLoadMore, !isPageLoading else { return }
        guard case .loaded(let render) = state else { return }
        guard currentIndex >= render.items.count - threshold else { return }
        
        isPageLoading = true
        paginationTask = Task { [weak self] in
            guard let self else { return }
            defer { self.isPageLoading = false }
            
            do {
                try await loadRemoteUseCase.loadMore(service: service)
                let snapshot = await loadRemoteUseCase.currentSnapshot(service: service)
                self.canLoadMore = snapshot.canLoadMore
                self.playlistsByID = snapshot.byID
                await MainActor.run {
                    self.state = .loaded(self.makeRenderModel(orderedIDs: snapshot.orderedIDs, playlistsByID: self.playlistsByID))
                }
            } catch {
                self.state = .error
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
        initialLoadTask?.cancel()
    }
}

private extension RemotePlaylistsSelectionViewModel {
    func makeRenderModel(orderedIDs: [PlaylistID], playlistsByID: [PlaylistID: Playlist]) -> RenderModel {
        let rowsByID: [PlaylistID: PlaylistRowVM] = orderedIDs.reduce(into: [:]) { res, id in
            guard let playlist = playlistsByID[id] else { return }
            res[id] = PlaylistRowVM(id: id, title: playlist.name, subtitle: "", artwork: playlist.artwork, selected: draftSelections.contains(id))
        }
        
        return RenderModel(items: orderedIDs.map { .playlist($0) }, rowsByID: rowsByID)
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
