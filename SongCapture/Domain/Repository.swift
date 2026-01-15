//
//  Repository.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

protocol Repository {
    func savePlaylist(_ playlist: Playlist) async throws
    func saveGroup(_ group: PlaylistGroup) async throws
    
    func fetchSavedPlaylists() async throws -> [Playlist]
    func fetchSavedGroups() async throws -> [PlaylistGroup]
    func fetchPlaylists(from service: Service) async throws -> [Playlist]
}
