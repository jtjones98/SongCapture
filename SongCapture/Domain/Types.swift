//
//  Types.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

import Foundation

enum Service: Hashable {
    case appleMusic
    case spotify
}

struct Playlist: Hashable, Equatable {
    let id: PlaylistID
    let name: String
    let thumbnailURL: String
    let service: Service
}

struct PlaylistGroup: Hashable, Equatable {
    let id: PlaylistGroupID
    let name: String
    let playlists: [Playlist]
}

struct PlaylistID: Hashable {
    let rawValue: String
    init(_ rawValue: String) { self.rawValue = rawValue }
}

struct PlaylistGroupID: Hashable { let id: UUID }

struct Track: Hashable {
    let title: String
    let artist: String
    let artworkURL: URL?
}

extension Service {
    var title: String {
        switch self {
        case .appleMusic: "Apple Music"
        case .spotify: "Spotify"
        }
    }
    
    var imageName: String {
        switch self {
        case .appleMusic: "apple_music_logo"
        case .spotify: "spotify_logo"
        }
    }
}
