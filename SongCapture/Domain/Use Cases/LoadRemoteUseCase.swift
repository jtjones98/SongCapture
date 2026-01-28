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
    
    func reset(service: Service) async {
        await repository.resetPlaylists(for: service)
    }
    
    func loadMore(service: Service) async throws {
        try await repository.loadMorePlaylists(for: service)
    }
    
    func currentSnapshot(service: Service) async -> PlaylistSnapshot {
        await repository.currentPlaylists(for: service)
    }
}
