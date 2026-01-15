//
//  AddPlaylistsViewModel.swift
//  SongCapture
//
//  Created by John Jones on 1/12/26.
//

final class AddPlaylistsViewModel {
    
    private let repository: Repository
    private let selectionStore: PlaylistSelectionStore
    
    init(repository: Repository, selectionStore: PlaylistSelectionStore) {
        self.repository = repository
        self.selectionStore = selectionStore
    }
}
