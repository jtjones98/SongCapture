//
//  ListenViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

import Foundation

final class ListenViewModel: NSObject {
    
    enum ListenViewState {
        case idle
        case listening
        case listened(Track)
        case failed(ListenViewModelError)
    }
    
    enum ListenViewModelError: LocalizedError {
        case noMatchFound(message: String)
        case permissionNotGranted(title: String, message: String, settingsAction: String, cancelAction: String)
        case engineError(message: String)
        
        var errorDescription: String? {
            switch self {
            case .noMatchFound:
                return "No match found. Please try again."
            case .permissionNotGranted:
                return "Permission not granted to access microphone."
            case .engineError:
                return "An error occurred. Please try again."
            }
        }
    }
    
    var onStateChanged: ((ListenViewState) -> Void)?
    
    private var state: ListenViewState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }
    
    private var matcher: AudioMatcher
    
    private var listenTask: Task<Void, Never>?
    
    init(with matcher: AudioMatcher) {
        self.matcher = matcher
        super.init()
        
        configureMatcher()
    }
    
    @MainActor
    func listen() {
        switch state {
        case .listening:
            break
        case .idle, .listened, .failed:
            self.state = .listening
            
            listenTask?.cancel()
            listenTask = Task { [weak self] in
                guard let self else { return }
                do {
                    try await self.matcher.start()
                } catch let error as MatcherError {
                    await MainActor.run {
                        switch error {
                        case .permissionNotGranted:
                            self.state = .failed(.permissionNotGranted(title: "Permissions needed", message: "Please allow mic permissions in System Settings", settingsAction: "Open Settings", cancelAction: "Cancel"))
                        default:
                            self.state = .failed(.engineError(message: "Please try again."))
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.state = .failed(.engineError(message: "Please try again."))
                    }
                }
            }
        }
    }
    
    private func configureMatcher() {
        matcher.onMatch = { [weak self] track in
            guard let self else { return }
            Task { @MainActor in
                self.state = .listened(track)
            }
        }
        matcher.onNoMatch = { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.state = .failed(.noMatchFound(message: "No match found. Please try again."))
            }
        }
    }
    
    deinit {
        listenTask?.cancel()
    }
}

