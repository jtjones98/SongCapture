//
//  Repository.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

final class RepositoryImpl {
    
    private let auth: AuthService
    private let appleMusicRemote: MusicRemote
    private let spotifyRemote: MusicRemote
    
    var playlists: [PlaylistID: Playlist] = [:] // TODO: Implement disk storage
    var groups: [PlaylistGroupID: PlaylistGroup] = [:]
    
    init(auth: AuthService, appleMusicRemote: MusicRemote, spotifyRemote: MusicRemote) {
        self.auth = auth
        self.appleMusicRemote = appleMusicRemote
        self.spotifyRemote = spotifyRemote
    }
}

// MARK: - Library
extension RepositoryImpl: LibraryRepository {
    func fetchPlaylistsAndGroups() async throws -> (playlists: [Playlist], groups: [PlaylistGroup]) {
        let playlists = playlists.values.map { $0 } // TODO: Implement some sort of sorting
        let groups = groups.values.map { $0 }
        return (playlists, groups)
    }
    
    func fetchGroup(id: PlaylistGroupID) async throws -> PlaylistGroup? {
        groups[id]
    }
    
    func fetchPlaylists(ids: [PlaylistID]) async throws -> [Playlist] {
        ids.reduce(into: [Playlist]()) { result, id in
            if let playlist = playlists[id] {
                result.append(playlist)
            }
        }
    }
    
    func savePlaylistGroup(_ group: PlaylistGroup) async throws {
        groups[group.id] = group
    }
    
    func savePlaylist(_ playlist: Playlist) async throws {
        playlists[playlist.id] = playlist
    }
}

// MARK: - Remote
extension RepositoryImpl: RemoteRepository {
    func fetchPlaylists(from service: Service) async throws -> [Playlist] {
        switch service {
        case .appleMusic:
            try await appleMusicRemote.fetchPlaylists()
        case .spotify:
            [] // TODO: fetch spotify playlists
        }
    }
}

// MARK: - Service Authentication
extension RepositoryImpl: ServiceAuthRepository {
    func checkAuthorization(for service: Service) async throws -> Bool {
        switch service {
        case .appleMusic:
            return auth.isAuthorizedAppleMusic()
        case .spotify:
            return auth.isAuthorizedSpotify()
        }
    }
    
    func requestAuthorization(for service: Service) async throws {
        switch service {
        case .appleMusic:
            try await auth.requestAppleMusicAuthorization()
        case .spotify:
            try await auth.requestSpotifyAuthorization()
        }
    }
}
