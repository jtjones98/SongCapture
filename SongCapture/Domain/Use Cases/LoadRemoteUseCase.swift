//
//  LoadRemoteUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

protocol LoadRemoteUseCase {
    func fetchPlaylists(from service: Service) async throws -> [Playlist]
}

/// Use case for loading user's playlists from a service
final class LoadRemoteUseCaseImpl: LoadRemoteUseCase {
    
    private let repository: RemoteRepository
    
    init(repository: RemoteRepository) {
        self.repository = repository
    }
    
    func fetchPlaylists(from service: Service) async throws -> [Playlist] {
        try await repository.fetchPlaylists(from: service)
    }
}
