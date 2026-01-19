//
//  NewEditGroupViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/11/26.
//

import Foundation
import MusicKit

final class NewEditGroupViewModel {
    private let repository: Repository
    private let authService: AuthService
    private let selectionStore: PlaylistSelectionStore
    
    private var services: [Service: ServiceState] = [:]
    
    private var state: ViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((ViewState) -> Void)?
    
    private var requestAuthorizationTask: Task<Void, Never>?
    
    // TODO: Initialize with an auth service
    init(repository: Repository, authService: AuthService, selectionStore: PlaylistSelectionStore) {
        self.repository = repository
        self.authService = authService
        self.selectionStore = selectionStore
    }
    
    func getGroupPlaylists() {
        
    }
    
    func getPlaylists() {
        var services: [Service: ServiceState] = [
            .appleMusic: ServiceState(
                isAuthorized: false,
                playlists: [
//                    Playlist(id: PlaylistID(id: UUID()), name: "Fall '24", artwork: .none, service: .appleMusic),
//                    Playlist(id: PlaylistID(id: UUID()), name: "Jungle 2025", artwork: .none, service: .appleMusic),
//                    Playlist(id: PlaylistID(id: UUID()), name: "Chill", artwork: .none, service: .appleMusic),
//                    Playlist(id: PlaylistID(id: UUID()), name: "Winter '26", artwork: .none, service: .appleMusic),
//                    Playlist(id: PlaylistID(id: UUID()), name: "Ambient for s+t+j", artwork: .none, service: .appleMusic),
//                    Playlist(id: PlaylistID(id: UUID()), name: "Jungle 2026", artwork: .none, service: .appleMusic),
//                    Playlist(id: PlaylistID(id: UUID()), name: "Rest", artwork: .none, service: .appleMusic)
                ]
            ),
            .spotify: ServiceState(
                isAuthorized: false,
                playlists: [
                    Playlist(id: PlaylistID(UUID().uuidString), name: "Fall '24", artwork: .none, service: .spotify),
                    Playlist(id: PlaylistID(UUID().uuidString), name: "Jungle 2025", artwork: .none, service: .spotify),
                    Playlist(id: PlaylistID(UUID().uuidString), name: "Chill", artwork: .none, service: .spotify),
                    Playlist(id: PlaylistID(UUID().uuidString), name: "Winter '26", artwork: .none, service: .spotify),
                    Playlist(id: PlaylistID(UUID().uuidString), name: "Ambient for s+t+j", artwork: .none, service: .spotify),
                    Playlist(id: PlaylistID(UUID().uuidString), name: "Jungle 2026", artwork: .none, service: .spotify),
                    Playlist(id: PlaylistID(UUID().uuidString), name: "Rest", artwork: .none, service: .spotify)
                ]
            )
        ]
        
        self.services = services
        let renderModel = makeRenderModel(from: services)
        state = .loaded(renderModel)
    }
    
    func requestMusicAuthorization(for service: Service) {
        requestAuthorizationTask?.cancel()
        
        switch service {
        case .appleMusic:
            requestAuthorizationTask = Task {
                do {
                    try await authService.requestAppleMusicAuthorization()
                    services[.appleMusic]?.isAuthorized = true
                    await MainActor.run {
                        state = .loaded(makeRenderModel(from: self.services))
                    }
                } catch let AuthError {
                    // TODO: Add an AppLogger to log errors
                    await MainActor.run {
                        state = .error(.authFailure(title: "Authorization", body: "SongCapture needs Music access to access your music library", action: "Open Settings"))
                    }
                }
            }
        case .spotify:
            requestAuthorizationTask = Task {
                do {
                    try await authService.requestSpotifyAuthorization()
                    services[.spotify]?.isAuthorized = true
                    await MainActor.run {
                        state = .loaded(makeRenderModel(from: self.services))
                    }
                } catch {
                    await MainActor.run {
                        state = .error(.authFailure(title: "Authorization", body: "SongCapture needs Spotify access to access your music library", action: nil))
                    }
                }
            }
        }
    }
    
    deinit {
        requestAuthorizationTask?.cancel()
    }
}

// MARK: Helper

private extension NewEditGroupViewModel {
    func makeRenderModel(from services: [Service: ServiceState]) -> RenderModel {
        var sections: [Section] = []
        var itemsBySection: [Section: [Item]] = [:]
        
        for service in [Service.appleMusic, .spotify] {
            let state = services[service] ?? ServiceState(isAuthorized: false, playlists: [])
            if state.isAuthorized {
                let section: Section = .service(service)
                sections.append(section)
                if (!state.playlists.isEmpty) {
                    itemsBySection[section] = state.playlists.map { .playlist($0) }
                } else {
                    itemsBySection[section] = [.empty]
                }
            }
        }
        
        // Grant access section if needed
        let needsAccess = [Service.appleMusic, .spotify].filter {
            !(services[$0]?.isAuthorized ?? false)
        }
        
        if !needsAccess.isEmpty {
            sections.append(.grantAccess)
            itemsBySection[.grantAccess] = needsAccess.map { .grantAccess($0) }
        }
        
        return RenderModel(sections: sections, itemsBySection: itemsBySection)
    }
}

// MARK: Types

extension NewEditGroupViewModel {
    enum NewEditGroupError: LocalizedError {
        case authFailure(title: String, body: String, action: String?)
    }
}

extension NewEditGroupViewModel {
    
    enum ViewState {
        case idle
        case loading
        case loaded(RenderModel)
        case error(NewEditGroupError)
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
    
    // TODO: Maybe this shouldn't live here
    struct ServiceState {
        var isAuthorized: Bool
        var playlists: [Playlist]
    }
}

extension NewEditGroupViewModel.Section {
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
