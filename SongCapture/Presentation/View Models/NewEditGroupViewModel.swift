//
//  NewEditGroupViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/11/26.
//

import Foundation

final class NewEditGroupViewModel {
    private let store: PlaylistSelectionStore
    
    // private var services: [Service: ServiceState] = [:]
    
    private var state: ViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((ViewState) -> Void)?
    
    // TODO: Initialize with an auth service
    init(with store: PlaylistSelectionStore) {
        self.store = store
    }
    
    func getPlaylists() {
        var services: [Service: ServiceState] = [
            .appleMusic: ServiceState(
                isAuthorized: true,
                playlists: [
                    Playlist(id: UUID(), name: "Fall '24", thumbnailURL: "", service: .appleMusic),
                    Playlist(id: UUID(), name: "Jungle 2025", thumbnailURL: "", service: .appleMusic),
                    Playlist(id: UUID(), name: "Chill", thumbnailURL: "", service: .appleMusic),
                    Playlist(id: UUID(), name: "Winter '26", thumbnailURL: "", service: .appleMusic),
                    Playlist(id: UUID(), name: "Ambient for s+t+j", thumbnailURL: "", service: .appleMusic),
                    Playlist(id: UUID(), name: "Jungle 2026", thumbnailURL: "", service: .appleMusic),
                    Playlist(id: UUID(), name: "Rest", thumbnailURL: "", service: .appleMusic)
                ]
            ),
            .spotify: ServiceState(
                isAuthorized: true,
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
        
        var renderModel = makeRenderModel(from: services)
        state = .loaded(renderModel)
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
                itemsBySection[section] = state.playlists.map { .playlist($0) }
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
    
    enum ViewState {
        case idle
        case loading
        case loaded(RenderModel)
        case error(String)
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
