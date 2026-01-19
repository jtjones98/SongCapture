//
//  AddPlaylistsViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/12/26.
//

import UIKit

fileprivate typealias Section = AddPlaylistsViewModel.Section
fileprivate typealias Item = AddPlaylistsViewModel.Item
fileprivate typealias DataSource = UITableViewDiffableDataSource<Section, Item>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
fileprivate typealias RenderModel = AddPlaylistsViewModel.RenderModel

class AddPlaylistsViewController: UIViewController {
    
    private let viewModel: AddPlaylistsViewModel
    private weak var coordinator: PlaylistsAndGroupsCoordinating?
    
    private var tableView: UITableView!
    private var dataSource: DataSource!
    
    private var renderModel: RenderModel?
    
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
        view.backgroundColor = .systemBackground
        
        configureViewModel()
        configureTableView()
        configureDataSource()
        
        viewModel.fetchPlaylists()
    }
    
    private func configureViewModel() {
        viewModel.onStateChange = { [weak self] state in
            switch state {
            case .idle:
                break
            case .loading:
                // TODO: Loading spinner
                break
            case .loaded(let renderModel):
                print(renderModel)
                self?.applySnapshot(renderModel: renderModel)
            case .error:
                // TODO: Show some UI
                break
            }
        }
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsMultipleSelection = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            switch item {
            case .playlist(let id):
                if let playlist = self.renderModel?.rowsByID[id] {
                    print("jtj configuring playlist \(playlist.title) with id \(id) row")
                    let config = PlaylistRowConfiguration(title: playlist.title, artwork: playlist.artwork)
                    cell.contentConfiguration = config
                }
                return cell
            }
        }
    }
    
    private func applySnapshot(renderModel newRender: RenderModel) {
        // Update the stored render model reference first so state is consistent
        let oldRender = self.renderModel
        self.renderModel = newRender

        // If we have an old render and the items are identical, just reconfigure
        if let oldRender = oldRender, oldRender.items == newRender.items {
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems(newRender.items)
            dataSource.apply(snapshot, animatingDifferences: true)
            return
        }

        // Otherwise, build a fresh snapshot and apply
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(newRender.items)
        print("appending items: \(newRender.items)")
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension AddPlaylistsViewController: UITableViewDelegate {
    
}
