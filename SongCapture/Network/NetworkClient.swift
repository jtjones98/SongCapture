//
//  NetworkClient.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

import Foundation
import MusicKit

protocol NetworkClient {
    func fetchPlaylists(from service: Service) -> Data
}

final class NetworkClientImpl: NetworkClient {
    func fetchPlaylists(from service: Service) -> Data {
        // TODO: Network fetch playlists from services
        return Data()
    }
    
    private func fetchAppleMusicPlaylists() -> Data {
        // TODO: Network fetch apple music playlists
        return Data()
    }
    
    private func fetchSpotifyPlaylists() -> Data {
        // TODO: Network fetchc spotify playlists
        return Data()
    }
}
