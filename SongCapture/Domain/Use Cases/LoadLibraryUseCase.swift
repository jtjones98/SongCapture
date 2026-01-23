//
//  LoadLibraryUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

/// Use case for loading saved playlists and playlist groups
final class LoadLibraryUseCase {
    
    private let repository: LibraryRepository
    
    init(repository: LibraryRepository) {
        self.repository = repository
    }
    
    func fetchPlaylistsAndGroups() async throws -> (playlists: [Playlist], groups: [PlaylistGroup]) {
        try await repository.fetchPlaylistsAndGroups()
    }
}
