//
//  Types.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

import MusicKit
import Foundation

enum Service: Hashable {
    case appleMusic
    case spotify
}

struct Playlist: Hashable, Equatable {
    let id: PlaylistID
    let name: String
    let artwork: PlaylistArtwork
}

struct PlaylistGroup: Hashable, Equatable {
    let id: PlaylistGroupID
    var name: String
    var playlistIDs: [PlaylistID]
}

struct PlaylistID: Hashable {
    let service: Service
    let rawValue: String
}

struct PlaylistGroupID: Hashable {
    let id: UUID
    init() { id = UUID() }
}

enum PlaylistArtwork {
    case appleMusic(Artwork)
    case spotify(String)
    case none
}

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

extension Playlist {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}

extension PlaylistGroup {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: PlaylistGroup, rhs: PlaylistGroup) -> Bool {
        lhs.id == rhs.id
    }
}
