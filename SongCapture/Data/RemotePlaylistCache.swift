//
//  RemotePlaylistCache.swift
//  SongCapture
//
//  Created by John Jones on 1/24/26.
//

/// Cache for RemotePlaylistsSelection
actor RemotePlaylistCache {
    var orderedIDs: [PlaylistID] = []
    var playlistsByID: [PlaylistID: Playlist] = [:]
    var seen: Set<PlaylistID> = []
    
    var nextToken: String? = nil
    var canLoadMore: Bool = true
    var isLoading: Bool = false
    
    func reset() {
        orderedIDs = []
        playlistsByID = [:]
        seen = []
        nextToken = nil
        canLoadMore = true
        isLoading = false
    }
}

extension RemotePlaylistCache {
    func setLoading(_ val: Bool) {
        isLoading = val
    }
    
    func merge(page: PlaylistPage) {
        for playlist in page.items {
            if seen.insert(playlist.id).inserted {
                orderedIDs.append(playlist.id)
            }
            playlistsByID[playlist.id] = playlist
        }
        nextToken = page.nextToken
        canLoadMore = !page.reachedEnd
    }
    
    func currentSnapshot() -> PlaylistSnapshot {
        PlaylistSnapshot(orderedIDs: orderedIDs, byID: playlistsByID, canLoadMore: canLoadMore)
    }
}
