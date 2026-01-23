//
//  SaveGroupUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

/// Use case for saving a playlist group
final class SaveGroupUseCase {
    
    private let repository: LibraryRepository
    
    init(repository: LibraryRepository) {
        self.repository = repository
    }
    
    func savePlaylistGroup(_ group: PlaylistGroup) async throws {
        try await repository.savePlaylistGroup(group)
    }
}
