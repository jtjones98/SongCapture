//
//  Repository.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

import MusicKit

final class RepositoryImpl: Repository {
        
    private let appleMusicRemote: MusicRemoteDataSource
    private let spotifyRemote: MusicRemoteDataSource
    
    init(appleMusicRemote: MusicRemoteDataSource, spotifyRemote: MusicRemoteDataSource) {
        self.appleMusicRemote = appleMusicRemote
        self.spotifyRemote = spotifyRemote
    }
    
    func savePlaylist(_ playlist: Playlist) async throws {
        // TODO: Repo save playlist that user has chosen from their service playlists
    }
    
    func saveGroup(_ group: PlaylistGroup) async throws {
        // TODO: Repo save new playlist group user has created from new/edit group vc
    }
    
    func fetchSavedPlaylists() async throws -> [Playlist] {
        // TODO: Repo fetch their saved playlists from a data source (core data?)
        return []
    }
    
    func fetchSavedGroups() async throws -> [PlaylistGroup] {
        // TODO: Repo fetch saved groups from a data source (core data?)
        return []
    }
    
    func fetchPlaylists(from service: Service) async throws -> [Playlist] {
        switch service {
        case .appleMusic:
            try await appleMusicRemote.fetchPlaylists()
        case .spotify:
            try await spotifyRemote.fetchPlaylists()
        }
    }
}

// TODO: Create a store for saved playlists and playlist groups
