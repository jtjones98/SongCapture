//
//  PlaylistSelectionStore.swift
//  SongCapture
//
//  Created by John Jones on 1/11/26.
//

import UIKit

protocol PlaylistSelectionStore {
    func addObserver(_ handler: @escaping (Set<PlaylistID>) -> Void) -> UUID
    func removeObserver(_ id: UUID)
    func toggle(_ id: PlaylistID)
}

final class PlaylistSelectionStoreImpl: PlaylistSelectionStore {
        
    // TODO: Look into Combine alternative
    private var observers: [UUID: (Set<PlaylistID>) -> Void] = [:] {
        didSet {
            notifyObservers()
        }
    }
    
    private(set) var selectedIDs: Set<PlaylistID> = [] {
        didSet {
            notifyObservers()
        }
    }
    
    func addObserver(_ handler: @escaping (Set<PlaylistID>) -> Void) -> UUID {
        let id = UUID()
        observers[id] = handler
        handler(selectedIDs)
        return id
    }
    
    func removeObserver(_ id: UUID) {
        observers[id] = nil
    }
    
    private func notifyObservers() {
        for handler in observers.values {
            handler(selectedIDs)
        }
    }
    
    func isSelected(_ id: PlaylistID) -> Bool {
        selectedIDs.contains(id)
    }
    
    func toggle(_ id: PlaylistID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}
