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
        request.limit = 25
        
        let response = try await request.response()
        print("apple music response: \(response)")
        print("items: \(response.items)")
        
        return response.items.map { item in
            var artwork: PlaylistArtwork
            if let artwk = item.artwork {
                artwork = .appleMusic(artwk)
            } else {
                artwork = .none
            }
            
            return Playlist(
                id: PlaylistID(item.id.rawValue),
                name: item.name,
                artwork: artwork,
                service: .appleMusic
            )
        }
    }
}

