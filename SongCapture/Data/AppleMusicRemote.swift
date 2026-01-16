//
//  AppleMusicRemote.swift
//  SongCapture
//
//  Created by John Jones on 1/16/26.
//
import Foundation
import MusicKit

final class AppleMusicRemote: MusicRemoteDataSource {
    func fetchPlaylists() async throws -> [Playlist] {
        print("apple music remote: fetching playlists")
        var request = MusicLibraryRequest<MusicKit.Playlist>()
        request.sort(by: \.name, ascending: true)
        request.limit = 8
        
        let response = try await request.response()
        print("apple music response: \(response)")
        print("items: \(response.items)")
        return response.items.map { item in
            Playlist(
                id: PlaylistID(item.id.rawValue),
                name: item.name,
                thumbnailURL: item.artwork?.url(width: 56, height: 56)?.absoluteString ?? "",
                service: .appleMusic
            )
        }
    }
}
