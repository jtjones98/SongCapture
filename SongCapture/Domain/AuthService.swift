//
//  AuthService.swift
//  SongCapture
//
//  Created by John Jones on 1/20/26.
//

protocol AuthService {
    func requestAppleMusicAuthorization() async throws
    func requestSpotifyAuthorization() async throws
    func isAuthorizedAppleMusic() -> Bool
    func isAuthorizedSpotify() -> Bool
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
