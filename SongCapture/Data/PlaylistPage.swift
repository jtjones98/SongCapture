//
//  PlaylistPage.swift
//  SongCapture
//
//  Created by John Jones on 1/24/26.
//

struct PlaylistPage {
    let items: [Playlist]
    let nextToken: String? // how to get the next page may differ by provider, Spotify not implemented yet so this is an unknown
    let reachedEnd: Bool
}
