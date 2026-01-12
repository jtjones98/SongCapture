//
//  UploadViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/12/26.
//

final class UploadViewModel {
    
    private var matcher: AudioMatcher
    
    init(with matcher: AudioMatcher) {
        self.matcher = matcher
        
        configureMatcher()
    }
    
    func configureMatcher() {
        // TODO: configure matcher
    }
}
