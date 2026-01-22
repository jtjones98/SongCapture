//
//  LibraryRepository.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//


protocol LibraryRepository {
    func fetchPlaylistsAndGroups() async throws -> (playlists: [Playlist], groups: [PlaylistGroup])
    func fetchGroup(id: PlaylistGroupID) async throws -> PlaylistGroup?
    func fetchPlaylists(ids: [PlaylistID]) async throws -> [Playlist]
    
    func savePlaylistGroup(_ group: PlaylistGroup) async throws
    func savePlaylist(_ playlist: Playlist) async throws
}
