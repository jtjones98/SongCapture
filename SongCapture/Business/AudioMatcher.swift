//
//  AudioMatcher.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

protocol AudioMatcher {
    var onMatch: ((Track) -> Void)? { get set }
    var onNoMatch: (() -> Void)? { get set }
    func start() async throws
    func stop()
}
