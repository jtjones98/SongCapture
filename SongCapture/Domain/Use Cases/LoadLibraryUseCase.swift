//
//  LoadLibraryUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

protocol LoadLibraryUseCase {
    func fetchPlaylistsAndGroups() async throws -> (playlists: [Playlist], groups: [PlaylistGroup])
}

/// Use case for loading saved playlists and playlist groups
final class LoadLibraryUseCaseImpl: LoadLibraryUseCase {
    
    private let repository: LibraryRepository
    
    init(repository: LibraryRepository) {
        self.repository = repository
    }
    
    func fetchPlaylistsAndGroups() async throws -> (playlists: [Playlist], groups: [PlaylistGroup]) {
        try await repository.fetchPlaylistsAndGroups()
    }
}
