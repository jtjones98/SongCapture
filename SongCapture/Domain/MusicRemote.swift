//
//  MusicRemote.swift
//  SongCapture
//
//  Created by John Jones on 1/20/26.
//

protocol MusicRemote {
    func fetchPlaylists() async throws -> [Playlist]
}
