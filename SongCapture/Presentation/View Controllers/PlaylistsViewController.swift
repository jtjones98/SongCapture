//
//  PlaylistsViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/12/26.
//

import UIKit

class PlaylistsViewController: UIViewController {
    
    private let viewModel: PlaylistsViewModel
    private weak var coordinator: PlaylistGroupsCoordinating?
    
    init(with viewModel: PlaylistsViewModel, coordinator: PlaylistGroupsCoordinating) {
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
