//
//  SaveGroupUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

protocol SaveGroupUseCase {
    func savePlaylistGroup(_ group: PlaylistGroup) async throws
}

/// Use case for saving a playlist group
final class SaveGroupUseCaseImpl: SaveGroupUseCase {
    
    private let repository: LibraryRepository
    
    init(repository: LibraryRepository) {
        self.repository = repository
    }
    
    func savePlaylistGroup(_ group: PlaylistGroup) async throws {
        try await repository.savePlaylistGroup(group)
    }
}
