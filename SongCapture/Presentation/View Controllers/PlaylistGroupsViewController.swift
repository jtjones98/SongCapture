//
//  PlaylistGroupsViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

import UIKit

fileprivate typealias Section = PlaylistGroupsViewModel.Section
fileprivate typealias Item = PlaylistGroupsViewModel.Item
fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

final class PlaylistGroupsViewController: UIViewController {
    private var collectionView: UICollectionView!
    
    private var dataSource: DataSource!
    
    private var viewModel: PlaylistGroupsViewModel
    private weak var coordinator: PlaylistGroupsCoordinating?
    
    init(with viewModel: PlaylistGroupsViewModel, coordinator: PlaylistGroupsCoordinating) {
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
        title = "Playlist Groups"
        navigationItem.largeTitleDisplayMode = .automatic
        
        configureViewModel()
        configureCollectionView()
        configureDataSource()
        
        viewModel.loadPlaylistGroups()
    }
    
    private func configureViewModel() {
        viewModel.onStateChange = { [weak self] state in
            switch state {
            case .idle:
                break
            case .loading:
                break
            case .loaded(let items):
                self?.applySnapshot(with: items)
            }
        }
    }
    
    // MARK: CollectionView Config
    
    private func configureCollectionView() {
        let layout = makeLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        // Register cell
        collectionView.register(PlaylistGroupCell.self, forCellWithReuseIdentifier: PlaylistGroupCell.reuseIdentifier)
        collectionView.register(AddNewGroupCell.self, forCellWithReuseIdentifier: AddNewGroupCell.reuseIdentifier)
        
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
        let layout = UICollectionViewCompositionalLayout { (_, environment) -> NSCollectionLayoutSection? in
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
            case .item(let cellItem):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistGroupCell.reuseIdentifier, for: indexPath) as? PlaylistGroupCell else {
                    return UICollectionViewCell()
                }
                cell.configure(title: cellItem.title)
                return cell
            case .add:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddNewGroupCell.reuseIdentifier, for: indexPath) as? AddNewGroupCell else {
                    return UICollectionViewCell()
                }
                cell.configure(title: "Add new group")
                return cell
            }
        }
    }
    
    private func applySnapshot(with items: [Item], animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
}

// MARK: CollectionView Delegate

extension PlaylistGroupsViewController: UICollectionViewDelegate {
    // TODO: Implement zoom style transition from cell to view controller
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .item(_):
            // TODO: Navigate to page where users can edit playlist groups (this might end up being the same vc as add)
            break
        case .add:
            coordinator?.showNewEditGroup()
        }
    }
}

