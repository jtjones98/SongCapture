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
    func showGroupEditor(id: PlaylistGroupID?)
    func showRemotePlaylists(service: Service, preselections: Set<PlaylistID>, onSave: @escaping (Set<PlaylistID>, [PlaylistID: Playlist]) -> Void)
    func dismissGroupEditor()
}

@MainActor
final class AppCoordinator {
    
    private let window: UIWindow
    
    private let tabBarController = UITabBarController()
    
    // MARK: - Navigation Controllers
    private let uploadNav = UINavigationController()
    private let listenNav = UINavigationController()
    private let playlistsAndGroupsNav = UINavigationController()
    private let remotePlaylistsNav = UINavigationController()
    // Maybe a barcode scanning screen? Hmm...
    
    // MARK: - Dependencies
    private let authService: AuthService = AuthServiceImpl()
    private let appleMusicRemote: MusicRemote = AppleMusicRemote()
    private let spotifyRemote: MusicRemote = SpotifyRemote()
    private lazy var repository = RepositoryImpl(auth: authService, appleMusicRemote: appleMusicRemote, spotifyRemote: spotifyRemote)
    
    private lazy var loadLibraryUseCase = LoadLibraryUseCaseImpl(repository: repository)
    private lazy var loadGroupUseCase = LoadGroupUseCaseImpl(repository: repository)
    private lazy var saveGroupUseCase = SaveGroupUseCaseImpl(repository: repository)
    private lazy var savePlaylistUseCase = SavePlaylistUseCaseImpl(repository: repository)
    private lazy var connectServiceUseCase = ConnectServiceUseCaseImpl(repository: repository)
    private lazy var loadRemoteUseCase = LoadRemoteUseCaseImpl(repository: repository)
    
    private let audioMatcher: AudioMatcher = AudioMatcherImpl()
    private let imageLoader: ImageLoading = ImageLoader()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        PlaylistRowContentView.imageLoader = imageLoader // TODO: Rethink this... 
        
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
        let vm = PlaylistsAndGroupsViewModel(loadLibraryUseCase: loadLibraryUseCase)
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
    
    func showGroupEditor(id: PlaylistGroupID? = nil) {
        let vm = GroupEditorViewModel(groupID: id, loadGroupUseCase: loadGroupUseCase, saveGroupUseCase: saveGroupUseCase, savePlaylistUseCase: savePlaylistUseCase, connectServiceUseCase: connectServiceUseCase)
        let vc = GroupEditorViewController(with: vm, coordinator: self)
        vc.title = "New Group"
        
        playlistsAndGroupsNav.pushViewController(vc, animated: true)
    }
    
    func showRemotePlaylists(service: Service, preselections: Set<PlaylistID>, onSave: @escaping (Set<PlaylistID>, [PlaylistID : Playlist]) -> Void) {
        let vm = RemotePlaylistsSelectionViewModel(service: service, selections: preselections, loadRemoteUseCase: loadRemoteUseCase)
        let vc = RemotePlaylistsSelectionViewController(with: vm, coordinator: self)
        
        vm.onSave = { [weak self] selections, playlistsByID in
            onSave(selections, playlistsByID)
            self?.remotePlaylistsNav.dismiss(animated: true)
        }
        
        vc.title = "Playlists"
        
        remotePlaylistsNav.setViewControllers([vc], animated: true)
        remotePlaylistsNav.modalPresentationStyle = .formSheet
        
        if let sheet = remotePlaylistsNav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.selectedDetentIdentifier = .medium
        }
        
        playlistsAndGroupsNav.present(remotePlaylistsNav, animated: true)
    }
    
    func dismissGroupEditor() {
        playlistsAndGroupsNav.popToRootViewController(animated: true)
    }
}
