//
//  PlaylistsAndGroupsViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

import UIKit

fileprivate typealias Section = PlaylistsAndGroupsViewModel.Section
fileprivate typealias Item = PlaylistsAndGroupsViewModel.Item
fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
fileprivate typealias RenderModel = PlaylistsAndGroupsViewModel.RenderModel

final class PlaylistsAndGroupsViewController: UIViewController {
    private var collectionView: UICollectionView!
    
    private var dataSource: DataSource!
    
    private var viewModel: PlaylistsAndGroupsViewModel
    private weak var coordinator: PlaylistsAndGroupsCoordinating?
    
    init(with viewModel: PlaylistsAndGroupsViewModel, coordinator: PlaylistsAndGroupsCoordinating) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always
        
        configureViewModel()
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadPlaylistsAndGroups()
    }
    
    private func configureViewModel() {
        viewModel.onStateChange = { [weak self] state in
            switch state {
            case .idle:
                break
            case .loading:
                break
            case .loaded(let render):
                self?.applySnapshot(render: render)
            }
        }
    }
    
    // MARK: CollectionView Config
    
    private func configureCollectionView() {
        let layout = makeLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        // Register cells
        collectionView.register(AddNewRowCollectionViewCell.self, forCellWithReuseIdentifier: AddNewRowCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.reuseIdentifier)
        collectionView.register(PlaylistGroupCell.self, forCellWithReuseIdentifier: PlaylistGroupCell.reuseIdentifier)
        collectionView.register(AddNewGroupCell.self, forCellWithReuseIdentifier: AddNewGroupCell.reuseIdentifier)
        
        // Register header
        collectionView.register(CollectionSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionSectionHeader.reuseID)
        
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            // Section 0: List-style for PlaylistCell
            if sectionIndex == 0 {
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.showsSeparators = true
                config.backgroundColor = .clear
                
                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
            }

            // Section 1: Grid-style for PlaylistGroupCell (existing behavior)
            let width = environment.container.effectiveContentSize.width

            let columns: Int
            if width >= 900 {
                columns = 4
            } else if width >= 700 {
                columns = 3
            } else {
                columns = 2
            }

            let itemWidth = 1.0 / CGFloat(columns)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(itemWidth),
                heightDimension: .estimated(120)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(120)
            )

            let items = Array(repeating: item, count: columns)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)

            let section = NSCollectionLayoutSection(group: group)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            section.interGroupSpacing = 12
            return section
        }
        return layout
    }
    
    // MARK: Data Source + Snapshot

    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .playlist(let playlist):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                cell.contentConfiguration = PlaylistRowConfiguration(title: playlist.name, subtitle: "\(playlist.id.service)", image: nil, artwork: playlist.artwork)
                return cell
            case .group(let group):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistGroupCell.reuseIdentifier, for: indexPath) as? PlaylistGroupCell else {
                    return UICollectionViewCell()
                }
                cell.configure(title: group.name)
                return cell
            case .addPlaylist:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                    .applying(UIImage.SymbolConfiguration(scale: .large))
                let plusImage = UIImage(systemName: "plus", withConfiguration: symbolConfig)
                // TODO: Get title from item
                cell.contentConfiguration = PlaylistRowConfiguration(title: "Add new playlist", image: plusImage)
                return cell
            case .addGroup:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddNewGroupCell.reuseIdentifier, for: indexPath) as? AddNewGroupCell else {
                    return UICollectionViewCell()
                }
                // TODO: Get title from item
                cell.configure(title: "Create new group")
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionSectionHeader.reuseID, for: indexPath) as? CollectionSectionHeader else {
                return nil
            }
            
            guard let section = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section] else { return header }
            switch section {
            case .playlists:
                header.configure(title: "Playlists")
            case .groups:
                header.configure(title: "Groups")
            }
            
            return header
        }
    }
    
    private func applySnapshot(render: RenderModel, animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(render.sections)
        
        for section in render.sections {
            if let items = render.itemsBySection[section] {
                snapshot.appendItems(items, toSection: section)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
}

// MARK: CollectionView Delegate

extension PlaylistsAndGroupsViewController: UICollectionViewDelegate {
    // TODO: Implement zoom style transition from cell to view controller
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .playlist(_):
            // TODO: Navigate to a page where user can see previous uploads
            break
        case .group(let group):
            coordinator?.showGroupEditor(id: group.id)
            break
        case .addPlaylist:
            // TODO: Navigate to page where users can view remote playlists and add
            break
        case .addGroup:
            coordinator?.showGroupEditor(id: nil)
        }
    }
}
