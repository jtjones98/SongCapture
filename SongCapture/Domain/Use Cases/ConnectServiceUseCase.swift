//
//  ConnectServiceUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

/// Use case for connecting a streaming service.
final class ConnectServiceUseCase {
    
    private let repository: MusicAuthRepository
    
    init(repository: MusicAuthRepository) {
        self.repository = repository
    }
    
    func checkAuthorization(for service: Service) async throws -> Bool {
        try await repository.checkAuthorization(for: service)
    }
    
    func requestAuthorization(for service: Service) async throws {
        try await repository.requestAuthorization(for: service)
    }
}
