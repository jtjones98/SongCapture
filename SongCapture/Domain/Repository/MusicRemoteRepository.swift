//
//  MusicRemoteRepository.swift
//  SongCapture
//
//  Created by John Jones on 1/21/26.
//

protocol MusicRemoteRepository {
    func resetPlaylists(for service: Service) async
    func loadMorePlaylists(for service: Service) async throws
    func currentPlaylists(for service: Service) async -> PlaylistSnapshot
}
