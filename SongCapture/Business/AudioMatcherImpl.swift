//
//  AudioMatcherImpl.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

import ShazamKit

enum MatcherError: Error {
    case permissionNotGranted
    case sessionConfigFailure
    case audioEngineFailure
    case shazamFailure(String)
}

final class AudioMatcherImpl: NSObject, AudioMatcher {
    var onMatch: ((Track) -> Void)?
    
    var onNoMatch: (() -> Void)?
    
    private let audioSession = AVAudioSession.sharedInstance()
    private let shazamSession = SHSession()
    
    private let audioEngine = AVAudioEngine()
    private var isListening = false
    
    func start() async throws {
        // 1) Request Permission
        let granted = await requestMicPermissionsIfNeeded()
        guard granted else {
            print("Mic permissions not granted")
            throw MatcherError.permissionNotGranted
        }
        
        print("Mic permissions granted")
        
        // 2) Configure Audio Session
        do {
            try configureAudioSession()
            print("Audio Session configured")
        } catch {
            // TODO: Add proper logging
            print("Failed to configure audio session: \(error)")
            throw MatcherError.sessionConfigFailure
        }
        
        // 3) Start engine and tap
        do {
            try startAudioEngineAndStreamToShazam()
            isListening = true
            print("Audio Engine and Stream to Shazam started")
        } catch {
            // TODO: Add proper logging
            print(error.localizedDescription)
            throw MatcherError.audioEngineFailure
        }
    }
    
    func stop() {
        print("Audio Engine listening stopped")
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        isListening = false
    }
    
    private func requestMicPermissionsIfNeeded() async -> Bool {
        // TODO: Add permissions logging
        return await AVAudioApplication.requestRecordPermission()
    }
    
    private func configureAudioSession() throws {
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
    }
    
    private func startAudioEngineAndStreamToShazam() throws {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, audioTime in
            self?.shazamSession.matchStreamingBuffer(buffer, at: audioTime)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}
    
extension AudioMatcherImpl: SHSessionDelegate {
    
    func session(_ session: SHSession, didFind match: SHMatch) {
        stop()
        
        let item = match.mediaItems.first
        
        let track = Track(title: item?.title ?? "Unknown title",
                          artist: item?.artist ?? "Unknown artist",
                          artworkURL: item?.artworkURL
        )
        
        onMatch?(track)
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        stop()
        // TODO: Add proper logging
        if let error {
            print("Shazam failed with: \(error)")
        }
        onNoMatch?()
    }
}
