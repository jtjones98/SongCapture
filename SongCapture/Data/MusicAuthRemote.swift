//
//  MusicAuthRemote.swift
//  SongCapture
//
//  Created by John Jones on 1/20/26.
//
import MusicKit

protocol MusicAuthRemote {
    func requestAppleMusicAuthorization() async throws
    func requestSpotifyAuthorization() async throws
    func isAuthorizedAppleMusic() -> Bool
    func isAuthorizedSpotify() -> Bool
}

enum MusicAuthError: Error, CustomDebugStringConvertible {
    case authorizationDenied
    case unknown
    
    var debugDescription: String {
        switch self {
        case .authorizationDenied:
            return "Authorization was denied or restricted. User needs to enable access in Settings."
        case .unknown:
            return "An unknown authorization error occurred."
        }
    }
}

final class MusicAuthRemoteImpl: MusicAuthRemote {
    func requestAppleMusicAuthorization() async throws {
        let authorizationStatus = await MusicAuthorization.request()
        switch authorizationStatus {
        case .authorized:
            break
        case .denied, .restricted:
            throw MusicAuthError.authorizationDenied
        case .notDetermined:
            break
        @unknown default:
            throw MusicAuthError.unknown
        }
    }
    
    func requestSpotifyAuthorization() async throws {
        // TODO: - Request Spotify Authorization
    }
    
    func isAuthorizedAppleMusic() -> Bool {
        let status = MusicAuthorization.currentStatus
        return status == .authorized
    }
    
    func isAuthorizedSpotify() -> Bool {
        // TODO: - Implement real Spotify auth state check
        return false
    }
}

