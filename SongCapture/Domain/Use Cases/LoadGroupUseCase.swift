//
//  LoadGroupUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

/// Use case for loading a saved group's details
final class LoadGroupUseCase {
    
    private let repository: LibraryRepository
    
    init(repository: LibraryRepository) {
        self.repository = repository
    }

    func fetchGroup(id: PlaylistGroupID) async throws -> PlaylistGroup? {
        try await repository.fetchGroup(id: id)
    }
    
    func fetchPlaylists(ids: [PlaylistID]) async throws -> [Playlist] {
        try await repository.fetchPlaylists(ids: ids)
    }
}
