//
//  RemoteRepository.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

protocol RemoteRepository {
    func fetchPlaylists(from service: Service) async throws -> [Playlist]
}
