//
//  ServiceAuthRepository.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

protocol ServiceAuthRepository {
    func checkAuthorization(for service: Service) async throws -> Bool
    func requestAuthorization(for service: Service) async throws
}
