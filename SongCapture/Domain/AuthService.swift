//
//  AuthService.swift
//  SongCapture
//
//  Created by John Jones on 1/13/26.
//

import MusicKit
import Foundation

protocol AuthService: AnyObject {
    func requestAppleMusicAuthorization() async throws
    func requestSpotifyAuthorization() async throws
}

enum AuthError: Error, CustomDebugStringConvertible {
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
        // TODO: setup Spotify authorization
    }
}

