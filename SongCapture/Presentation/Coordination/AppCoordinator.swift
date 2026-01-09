//
//  AppCoordinator.swift
//  SongCapture
//
//  Created by John Jones on 1/8/26.
//

import UIKit

class AppCoordinator {
    
    private let navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }()
    
    var rootViewController: UIViewController {
        navigationController
    }
    
    private let audioMatcher: AudioMatcher = AudioMatcherImpl()
    
    private func makePlaylistGroupsViewModel() -> PlaylistGroupsViewModel {
        return PlaylistGroupsViewModel(with: audioMatcher)
    }
    
    func start() {
        let vm = makePlaylistGroupsViewModel()
        let vc = PlaylistGroupsViewController(with: vm)
        navigationController.setViewControllers([vc], animated: false)
    }
}
