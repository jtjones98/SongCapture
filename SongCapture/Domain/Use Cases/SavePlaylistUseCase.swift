//
//  SavePlaylistUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

protocol SavePlaylistUseCase {
    func savePlaylist(_ playlist: Playlist) async throws
}

/// Use case for saving a playlist group
final class SavePlaylistUseCaseImpl: SavePlaylistUseCase {
    
    private let repository: LibraryRepository
    
    init(repository: LibraryRepository) {
        self.repository = repository
    }
    
    func savePlaylist(_ playlist: Playlist) async throws {
        try await repository.savePlaylist(playlist)
    }
}
