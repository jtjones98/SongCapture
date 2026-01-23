//
//  GroupEditorViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/11/26.
//

import Combine
import Foundation
import MusicKit

final class GroupEditorViewModel {
    
    // Dependencies
    private let groupID: PlaylistGroupID?
    private let loadGroupUseCase: LoadGroupUseCase
    private let saveGroupUseCase: SaveGroupUseCase
    private let savePlaylistUseCase: SavePlaylistUseCase
    private let connectServiceUseCase: ConnectServiceUseCase

    private var draftGroup: PlaylistGroup = PlaylistGroup(id: PlaylistGroupID(), name: "", playlistIDs: [])
    private var authStatusByService: [Service: Bool] = [:]
    private var playlistsByService: [Service: [Playlist]] = [:]
    
    @Published private(set) var state: ViewState = .idle

    var onAddPlaylists: (((service: Service, preselections: Set<PlaylistID>)) -> Void)?
    
    private var loadAuthAndPlaylistsTask: Task<Void, Never>?
    private var saveGroupTask: Task<Void, Never>?
    private var requestAuthorizationTask: Task<Void, Never>?
    
    init(groupID: PlaylistGroupID?, loadGroupUseCase: LoadGroupUseCase, saveGroupUseCase: SaveGroupUseCase, savePlaylistUseCase: SavePlaylistUseCase, connectServiceUseCase: ConnectServiceUseCase) {
        self.groupID = groupID
        self.loadGroupUseCase = loadGroupUseCase
        self.saveGroupUseCase = saveGroupUseCase
        self.savePlaylistUseCase = savePlaylistUseCase
        self.connectServiceUseCase = connectServiceUseCase
    }
    
    func loadDetails() {
        state = .loading
        
        loadAuthAndPlaylistsTask?.cancel()
        
        loadAuthAndPlaylistsTask = Task { [weak self] in
            guard let self else { return }
            do {
                // load saved group if this view model was handed a groupID, else, create new
                if let saved = try await loadGroupUseCase.fetchGroup(id: groupID ?? PlaylistGroupID()) {
                    draftGroup = saved
                } else {
                    draftGroup = PlaylistGroup(id: PlaylistGroupID(), name: "", playlistIDs: [])
                }
                
                let services: [Service] = [.appleMusic, .spotify]
                do {
                    for service in services { // TODO: Do this in parallel (async let or taskGroup)
                        authStatusByService[service] = try await connectServiceUseCase.checkAuthorization(for: service)
                    }
                } catch {
                    // TODO: Handle auth check error
                }
                
                // load group's playlists
                do {
                    for service in services {
                        playlistsByService[service] = try await loadGroupUseCase.fetchPlaylists(ids: draftGroup.playlistIDs)
                    }
                } catch {
                    // TODO: Handle fetching group's playlists error
                }
                
                let renderModel = makeRenderModel(playlistGroup: draftGroup)
                await MainActor.run {
                    self.state = .loaded(renderModel)
                }
            } catch {
                // TODO: Handle load group edit details error
            }
        }
    }
    
    func requestMusicAuthorization(for service: Service) {
        requestAuthorizationTask?.cancel()
        
        requestAuthorizationTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await connectServiceUseCase.requestAuthorization(for: service)
                authStatusByService[service] = true
                self.state = .loaded(makeRenderModel(playlistGroup: draftGroup))
            } catch {
                await MainActor.run {
                    self.state = .error(.authFailure(title: "Authorization", body: "SongCapture needs access your music library", action: nil))
                }
            }
        }
    }
    
    func didTapAddPlaylist(for service: Service) {
        let preselections = Set(draftGroup.playlistIDs.filter { $0.service == service })
        onAddPlaylists?((service: service, preselections: preselections))
    }
    
    func applySelectedPlaylists(_ selections: Set<PlaylistID>, _ playlistByIDs: [PlaylistID: Playlist], for service: Service) {
        draftGroup.playlistIDs.removeAll { $0.service == service }
        draftGroup.playlistIDs.append(contentsOf: selections)
        
        saveGroupTask?.cancel()
        saveGroupTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                for playlistID in playlistByIDs.keys { // TODO: taskGroup or async let
                    try await self.savePlaylistUseCase.savePlaylist(playlistByIDs[playlistID]!)
                }
                
                try await self.saveGroupUseCase.savePlaylistGroup(self.draftGroup)
                
                for service in [Service.appleMusic, .spotify] {
                    playlistsByService[service] = try await loadGroupUseCase.fetchPlaylists(ids: draftGroup.playlistIDs)
                }
                await MainActor.run {
                    self.state = .loaded(self.makeRenderModel(playlistGroup: self.draftGroup))
                }
            } catch {
                // TODO: Handle playlist group save failure
            }
        }
    }
    
    func updateGroupTitle(_ title: String) {
        saveGroupTask?.cancel()
        
        saveGroupTask = Task { [weak self] in
            guard let self else { return }
            self.draftGroup.name = title
            do {
                try await self.saveGroupUseCase.savePlaylistGroup(self.draftGroup)
            } catch {
                // TODO: Handle playlist group save failure
            }
        }        
    }
    
    deinit {
        requestAuthorizationTask?.cancel()
    }
}

// MARK: Helper
private extension GroupEditorViewModel {
    func makeRenderModel(playlistGroup: PlaylistGroup) -> RenderModel {
        var sections: [Section] = []
        var itemsBySection: [Section: [Item]] = [:]
        
        let services: [Service] = [.appleMusic, .spotify]
        let authorizedServices: [Service] = services.filter { authStatusByService[$0] == true }
        let unauthorizedServices: [Service] = services.filter { authStatusByService[$0] == false }
        
        authorizedServices.forEach { service in
            let section = Section.service(service)
            sections.append(section)
            let playlists = playlistsByService[service] ?? []
            itemsBySection[section] = playlists.map { Item.playlist($0) }
        }
        
        if !unauthorizedServices.isEmpty {
            sections.append(.grantAccess)
            itemsBySection[.grantAccess] = unauthorizedServices.map { Item.grantAccess($0) }
        }
        
        return RenderModel(sections: sections, itemsBySection: itemsBySection)
    }
}

// MARK: Types
extension GroupEditorViewModel {
    enum GroupEditorError: LocalizedError {
        case authFailure(title: String, body: String, action: String?)
    }
}

extension GroupEditorViewModel {
    
    enum ViewState {
        case idle
        case loading
        case loaded(RenderModel)
        case error(GroupEditorError)
    }
    
    struct RenderModel {
        let sections: [Section]
        let itemsBySection: [Section: [Item]]
    }
    
    // TODO: Add a recent uploads section?
    enum Section: Hashable {
        case service(Service)
        case grantAccess
    }
    
    enum Item: Hashable {
        case empty
        case playlist(Playlist)
        case grantAccess(Service)
    }
}

extension GroupEditorViewModel.Section {
    var title: String {
        switch self {
        case .service(let service): service.title
        case .grantAccess: "Connect a Service"
        }
    }
    
    var imageName: String? {
        switch self {
        case .service(let service): service.title
        case .grantAccess: nil
        }
    }
    
    var footerTitle: String { "Add Playlists" }
}

