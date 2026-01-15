//
//  AppCoordinator.swift
//  SongCapture
//
//  Created by John Jones on 1/8/26.
//

import UIKit

protocol AddSongsCoordinating: AnyObject {
    func showPlaylistsAndGroups()
}

protocol PlaylistsAndGroupsCoordinating: AnyObject {
    func showNewEditGroup()
    func showPlaylists()
}

@MainActor
final class AppCoordinator {
    
    private let window: UIWindow
    
    private let tabBarController = UITabBarController()
    
    private let uploadNav = UINavigationController()
    private let listenNav = UINavigationController()
    private let playlistsAndGroupsNav = UINavigationController()
    // TODO: Maybe a barcode scanning screen?
    
    private let audioMatcher: AudioMatcher = AudioMatcherImpl()
    private let playlistSelectionStore: PlaylistSelectionStore = PlaylistSelectionStoreImpl()
    private let authService: AuthService = AuthServiceImpl()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        setupUploadTab()
        setupListenTab()
        setupPlaylistsAndGroupsTab()
        
        tabBarController.setViewControllers([uploadNav, listenNav, playlistsAndGroupsNav], animated: false)
        tabBarController.selectedIndex = 0
        
        [uploadNav, listenNav, playlistsAndGroupsNav].forEach { $0.navigationBar.prefersLargeTitles = true }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    // MARK: Tabs setup
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
    
    private func setupPlaylistsAndGroupsTab() {
        let vm = PlaylistsAndGroupsViewModel()
        let vc = PlaylistsAndGroupsViewController(with: vm, coordinator: self)
        vc.title = "Playlists & Groups"
        vc.tabBarItem = UITabBarItem(title: "Playlists & Groups", image: UIImage(systemName: "rectangle.3.group"), tag: 2)
        
        playlistsAndGroupsNav.setViewControllers([vc], animated: false)
    }
}

// MARK: Add Songs Coordinating
extension AppCoordinator: AddSongsCoordinating {
    func showPlaylistsAndGroups() {
        // TODO: Navigate to playlists and groups
    }
}

// MARK: Playlist and Groups Coordinating
extension AppCoordinator: PlaylistsAndGroupsCoordinating {
    func showNewEditGroup() {
        let vm = NewEditGroupViewModel(with: playlistSelectionStore, authService: authService)
        let vc = NewEditGroupViewController(with: vm, coordinator: self)
        vc.title = "New Group"

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet

        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.selectedDetentIdentifier = .medium
        }

        playlistsAndGroupsNav.present(nav, animated: true)
    }
    
    func showPlaylists() {
        let vm = AddPlaylistsViewModel(with: playlistSelectionStore)
        let vc = AddPlaylistsViewController(with: vm, coordinator: self)
        vc.title = "Playlists"
        playlistsAndGroupsNav.pushViewController(vc, animated: true)
    }
}

