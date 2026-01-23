//
//  LoadRemoteUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

/// Use case for loading user's playlists from a service
final class LoadRemoteUseCase {
    
    private let repository: MusicRemoteRepository
    
    init(repository: MusicRemoteRepository) {
        self.repository = repository
    }
    
    func fetchPlaylists(from service: Service) async throws -> [Playlist] {
        try await repository.fetchPlaylists(from: service)
    }
}
