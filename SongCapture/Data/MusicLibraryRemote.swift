//
//  MusicLibraryRemote.swift
//  SongCapture
//
//  Created by John Jones on 1/20/26.
//
import MusicKit

protocol MusicLibraryRemote {
    func fetchFirstPlaylistPage(limit: Int) async throws -> PlaylistPage
    func fetchNextPlaylistPage(limit: Int, nextToken: String?) async throws -> PlaylistPage
}

final class AppleMusicRemote: MusicLibraryRemote {
    func fetchFirstPlaylistPage(limit: Int) async throws -> PlaylistPage {
        try await fetchNextPlaylistPage(limit: limit, nextToken: nil)
    }
    
    func fetchNextPlaylistPage(limit: Int, nextToken: String?) async throws -> PlaylistPage {
        let offset = Int(nextToken ?? "0") ?? 0
        
        var request = MusicLibraryRequest<MusicKit.Playlist>()
        request.sort(by: \.name, ascending: true)
        request.limit = limit
        request.offset = offset
        
        let response = try await request.response()
        
        let playlists: [Playlist] = response.items.map { item in
            let artwork: PlaylistArtwork = item.artwork.map(PlaylistArtwork.appleMusic) ?? .none
            return Playlist(
                id: PlaylistID(service: .appleMusic, rawValue: item.id.rawValue),
                name: item.name,
                artwork: artwork
            )
        }
        
        let reachedEnd = playlists.count < limit
        let next = reachedEnd ? nil : String(offset + limit)
        
        return PlaylistPage(items: playlists, nextToken: next, reachedEnd: reachedEnd)
    }
}

final class SpotifyRemote: MusicLibraryRemote {
    func fetchFirstPlaylistPage(limit: Int) async throws -> PlaylistPage {
        try await fetchNextPlaylistPage(limit: limit, nextToken: nil)
    }
    
    func fetchNextPlaylistPage(limit: Int, nextToken: String?) async throws -> PlaylistPage {
        // TODO: Fetch next page of spotify playlists
        return PlaylistPage(items: [], nextToken: nil, reachedEnd: false)
    }
}
