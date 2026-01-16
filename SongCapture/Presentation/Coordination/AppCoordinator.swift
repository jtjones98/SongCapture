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
    func showPlaylists(service: Service)
}

@MainActor
final class AppCoordinator {
    
    private let window: UIWindow
    
    private let tabBarController = UITabBarController()
    
    private let uploadNav = UINavigationController()
    private let listenNav = UINavigationController()
    private let playlistsAndGroupsNav = UINavigationController()
    private let newEditNav = UINavigationController()
    // TODO: Maybe a barcode scanning screen?
    
    private let networkClient: NetworkClient = NetworkClientImpl()
    private lazy var repository: Repository = RepositoryImpl(networkClient: networkClient)
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
        let vm = PlaylistsAndGroupsViewModel(repository: repository)
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
        let vm = NewEditGroupViewModel(repository: repository, authService: authService, selectionStore: playlistSelectionStore)
        let vc = NewEditGroupViewController(with: vm, coordinator: self)
        vc.title = "New Group"
        
        newEditNav.setViewControllers([vc], animated: true)
        newEditNav.modalPresentationStyle = .formSheet

        if let sheet = newEditNav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.selectedDetentIdentifier = .medium
        }

        playlistsAndGroupsNav.present(newEditNav, animated: true)
    }
    
    func showPlaylists(service: Service) {
        let vm = AddPlaylistsViewModel(service: service, repository: repository, selectionStore: playlistSelectionStore)
        let vc = AddPlaylistsViewController(with: vm, coordinator: self)
        vc.title = "Playlists"
        newEditNav.pushViewController(vc, animated: true)
    }
}

