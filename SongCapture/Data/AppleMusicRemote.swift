//
//  AppleMusicRemote.swift
//  SongCapture
//
//  Created by John Jones on 1/20/26.
//

import MusicKit

final class AppleMusicRemote: MusicRemote {
    func fetchPlaylists() async throws -> [Playlist] {
        var request = MusicLibraryRequest<MusicKit.Playlist>()
        request.sort(by: \.name, ascending: true)
        request.limit = 25
        
        let response = try await request.response()
        
        return response.items.map { item in
            var artwork: PlaylistArtwork
            if let artwk = item.artwork {
                artwork = .appleMusic(artwk)
            } else {
                artwork = .none
            }
            
            return Playlist(
                id: PlaylistID(service: .appleMusic, rawValue: item.id.rawValue),
                name: item.name,
                artwork: artwork,
            )
        }
    }
}
