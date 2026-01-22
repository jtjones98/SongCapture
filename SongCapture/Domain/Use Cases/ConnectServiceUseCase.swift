//
//  ConnectServiceUseCase.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

protocol ConnectServiceUseCase {
    func checkAuthorization(for service: Service) async throws -> Bool
    func requestAuthorization(for service: Service) async throws
}

/// Use case for connecting a streaming service.
final class ConnectServiceUseCaseImpl: ConnectServiceUseCase {
    
    private let repository: ServiceAuthRepository
    
    init(repository: ServiceAuthRepository) {
        self.repository = repository
    }
    
    func checkAuthorization(for service: Service) async throws -> Bool {
        try await repository.checkAuthorization(for: service)
    }
    
    func requestAuthorization(for service: Service) async throws {
        try await repository.requestAuthorization(for: service)
    }
}
