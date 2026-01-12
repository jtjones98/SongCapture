//
//  AppCoordinator.swift
//  SongCapture
//
//  Created by John Jones on 1/8/26.
//

import UIKit

protocol AddSongsCoordinating: AnyObject {
    func showPlaylistGroups()
}

protocol PlaylistGroupsCoordinating: AnyObject {
    func showEditGroup()
}

final class AppCoordinator {
    
    private let window: UIWindow
    
    private let tabBarController = UITabBarController()
    
    private let uploadNav = UINavigationController()
    private let listenNav = UINavigationController()
    private let playlistGroupsNav = UINavigationController()
    
    private let audioMatcher: AudioMatcher = AudioMatcherImpl()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        setupUploadTab()
        setupListenTab()
        setupPlaylistGroupsTab()
        
        tabBarController.setViewControllers([uploadNav, listenNav, playlistGroupsNav], animated: false)
        tabBarController.selectedIndex = 0
        
        [uploadNav, listenNav, playlistGroupsNav].forEach { $0.navigationBar.prefersLargeTitles = true }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    // MARK: Tab set up
    
    private func setupUploadTab() {
        let vm = UploadViewModel(with: audioMatcher)
        let vc = UploadViewController(with: vm, coordinator: self)
        vc.title = "Upload"
        vc.tabBarItem = UITabBarItem(title: "Upload", image: UIImage(systemName: "square.and.arrow.up.circle"), tag: 0)
        
        uploadNav.setViewControllers([vc], animated: false)
    }
    
    private func setupListenTab() {
        let vm = ListenViewModel(with: audioMatcher)
        let vc = ListenViewController(with: vm, coordinator: self)
        vc.title = "Listen"
        vc.tabBarItem = UITabBarItem(title: "Listen", image: UIImage(systemName: "waveform"), tag: 1)
        
        listenNav.setViewControllers([vc], animated: false)
    }
    
    private func setupPlaylistGroupsTab() {
        let vm = PlaylistGroupsViewModel()
        let vc = PlaylistGroupsViewController(with: vm, coordinator: self)
        vc.title = "Playlist Groups"
        vc.tabBarItem = UITabBarItem(title: "Playlist Groups", image: UIImage(systemName: "rectangle.3.group"), tag: 2)
        
        playlistGroupsNav.setViewControllers([vc], animated: false)
    }
}

extension AppCoordinator: AddSongsCoordinating {
    func showPlaylistGroups() {
        // TODO: Navigate to playlist groups
    }
}

extension AppCoordinator: PlaylistGroupsCoordinating {
    func showEditGroup() {
        // TODO: Navigation to edit group
    }
}
