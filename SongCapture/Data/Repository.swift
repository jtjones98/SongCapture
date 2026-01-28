//
//  Repository.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

final class Repository {
    
    private let auth: MusicAuthRemote
    private let appleMusicRemote: MusicLibraryRemote
    private let appleMusicCache: RemotePlaylistCache
    private let spotifyRemote: MusicLibraryRemote
    
    private let pageSize = 25
    
    var playlists: [PlaylistID: Playlist] = [:] // TODO: Implement disk storage
    var groups: [PlaylistGroupID: PlaylistGroup] = [:]
    
    init(auth: MusicAuthRemote, appleMusicRemote: MusicLibraryRemote, appleMusicCache: RemotePlaylistCache, spotifyRemote: MusicLibraryRemote) {
        self.auth = auth
        self.appleMusicRemote = appleMusicRemote
        self.appleMusicCache = appleMusicCache
        self.spotifyRemote = spotifyRemote
    }
}

// MARK: - Library
extension Repository: LibraryRepository {
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
extension Repository: MusicRemoteRepository {
    func resetPlaylists(for service: Service) async {
        switch service {
        case .appleMusic:
            await appleMusicCache.reset()
        case .spotify:
            break // TODO: reset spotify cache
        }
    }
    
    func loadMorePlaylists(for service: Service) async throws {
        switch service {
        case .appleMusic:
            try await loadMoreAppleMusicPlaylists()
        case .spotify:
            break
            // TODO: load more spotify playlists
        }
    }
    
    func currentPlaylists(for service: Service) async -> PlaylistSnapshot {
        switch service {
        case .appleMusic:
            return await appleMusicCache.currentSnapshot()
        case .spotify:
            // TODO: Get current spotify playlists
            return PlaylistSnapshot(orderedIDs: [], byID: [:], canLoadMore: false)
        }
    }
    
    private func loadMoreAppleMusicPlaylists() async throws {
        if await appleMusicCache.isLoading { return }
        if await appleMusicCache.canLoadMore == false { return }
        
        await appleMusicCache.setLoading(true)
        defer { Task { await self.appleMusicCache.setLoading(false) }}
        
        let token = await appleMusicCache.nextToken
        
        let page: PlaylistPage
        let isEmpty = await appleMusicCache.orderedIDs.isEmpty
        if token == nil && isEmpty {
            page = try await appleMusicRemote.fetchFirstPlaylistPage(limit: pageSize)
        } else {
            page = try await appleMusicRemote.fetchNextPlaylistPage(limit: pageSize, nextToken: token)
        }
        
        await appleMusicCache.merge(page: page)
    }
}

// MARK: - Service Authentication
extension Repository: MusicAuthRepository {
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
