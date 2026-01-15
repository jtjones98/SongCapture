//
//  AddPlaylistsViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/12/26.
//

import UIKit

class AddPlaylistsViewController: UIViewController {
    
    private let viewModel: AddPlaylistsViewModel
    private weak var coordinator: PlaylistsAndGroupsCoordinating?
    
    init(with viewModel: AddPlaylistsViewModel, coordinator: PlaylistsAndGroupsCoordinating) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
