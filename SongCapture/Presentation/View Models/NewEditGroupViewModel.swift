//
//  NewEditGroupViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/11/26.
//

import Foundation
import MusicKit

final class NewEditGroupViewModel {
    private let store: PlaylistSelectionStore
    private let authService: AuthService
    
    private var services: [Service: ServiceState] = [:]
    
    private var state: ViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((ViewState) -> Void)?
    
    private var requestAuthorizationTask: Task<Void, Never>?
    
    // TODO: Initialize with an auth service
    init(with store: PlaylistSelectionStore, authService: AuthService) {
        self.store = store
        self.authService = authService
    }
    
    func getPlaylists() {
        var services: [Service: ServiceState] = [
            .appleMusic: ServiceState(
                isAuthorized: false,
                playlists: [
//                    Playlist(id: UUID(), name: "Fall '24", thumbnailURL: "", service: .appleMusic),
//                    Playlist(id: UUID(), name: "Jungle 2025", thumbnailURL: "", service: .appleMusic),
//                    Playlist(id: UUID(), name: "Chill", thumbnailURL: "", service: .appleMusic),
//                    Playlist(id: UUID(), name: "Winter '26", thumbnailURL: "", service: .appleMusic),
//                    Playlist(id: UUID(), name: "Ambient for s+t+j", thumbnailURL: "", service: .appleMusic),
//                    Playlist(id: UUID(), name: "Jungle 2026", thumbnailURL: "", service: .appleMusic),
//                    Playlist(id: UUID(), name: "Rest", thumbnailURL: "", service: .appleMusic)
                ]
            ),
            .spotify: ServiceState(
                isAuthorized: false,
                playlists: [
                    Playlist(id: UUID(), name: "Fall '24", thumbnailURL: "", service: .spotify),
                    Playlist(id: UUID(), name: "Jungle 2025", thumbnailURL: "", service: .spotify),
                    Playlist(id: UUID(), name: "Chill", thumbnailURL: "", service: .spotify),
                    Playlist(id: UUID(), name: "Winter '26", thumbnailURL: "", service: .spotify),
                    Playlist(id: UUID(), name: "Ambient for s+t+j", thumbnailURL: "", service: .spotify),
                    Playlist(id: UUID(), name: "Jungle 2026", thumbnailURL: "", service: .spotify),
                    Playlist(id: UUID(), name: "Rest", thumbnailURL: "", service: .spotify)
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
    
    // TODO: Add a recent uploads section
    enum Section: Hashable {
        case service(Service)
        case grantAccess
    }
    
    enum Item: Hashable {
        case empty
        case playlist(Playlist)
        case grantAccess(Service)
    }
    
    enum Service: Hashable {
        case appleMusic
        case spotify
    }
    
    struct Playlist: Hashable, Equatable {
        let id: UUID
        let name: String
        let thumbnailURL: String
        let service: Service
    }
    
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

extension NewEditGroupViewModel.Service {
    var title: String {
        switch self {
        case .appleMusic: "Apple Music"
        case .spotify: "Spotify"
        }
    }
    
    var imageName: String {
        switch self {
        case .appleMusic: "apple_music_logo"
        case .spotify: "spotify_logo"
        }
    }
}
