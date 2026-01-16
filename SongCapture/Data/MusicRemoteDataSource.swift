//
//  MusicRemoteDataSource.swift
//  SongCapture
//
//  Created by John Jones on 1/16/26.
//

protocol MusicRemoteDataSource {
    func fetchPlaylists() async throws -> [Playlist]
}
