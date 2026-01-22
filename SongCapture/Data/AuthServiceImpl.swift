//
//  AuthServiceImpl.swift
//  SongCapture
//
//  Created by John Jones on 1/20/26.
//
import MusicKit

final class AuthServiceImpl: AuthService {
    func requestAppleMusicAuthorization() async throws {
        let authorizationStatus = await MusicAuthorization.request()
        switch authorizationStatus {
        case .authorized:
            break
        case .denied, .restricted:
            throw AuthError.authorizationDenied
        case .notDetermined:
            break
        @unknown default:
            throw AuthError.unknown
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
