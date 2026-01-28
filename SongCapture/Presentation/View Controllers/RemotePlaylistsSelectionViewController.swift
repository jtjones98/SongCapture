//
//  RemotePlaylistsSelectionViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/12/26.
//

import Combine
import UIKit

fileprivate typealias Section = RemotePlaylistsSelectionViewModel.Section
fileprivate typealias Item = RemotePlaylistsSelectionViewModel.Item
fileprivate typealias DataSource = UITableViewDiffableDataSource<Section, Item>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
fileprivate typealias RenderModel = RemotePlaylistsSelectionViewModel.RenderModel

class RemotePlaylistsSelectionViewController: UIViewController {
    
    private let viewModel: RemotePlaylistsSelectionViewModel
    private weak var coordinator: PlaylistsAndGroupsCoordinating?
    
    private var tableView: UITableView!
    private var dataSource: DataSource!
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var renderModel: RenderModel?
    
    init(with viewModel: RemotePlaylistsSelectionViewModel, coordinator: PlaylistsAndGroupsCoordinating) {
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .prominent, target: self, action: #selector(didTapAdd))
        
        configureViewModel()
        configureTableView()
        configureDataSource()
        
        viewModel.fetchFirstPage()
    }
    
    private func configureViewModel() {
        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .idle:
                    break
                case .loading:
                    // TODO: Loading spinner
                    break
                case .loaded(let renderModel):
                    self?.applySnapshot(renderModel: renderModel)
                case .error:
                    // TODO: Show some UI
                    break
                }
            }
            .store(in: &cancellables)
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
            cell.selectionStyle = .none
            
            switch item {
            case .playlist(let id):
                if let playlist = self.renderModel?.rowsByID[id] {
                    print("jtj configuring playlist \(playlist.title) with accessory: \(cell.accessoryType)")
                    let config = PlaylistRowConfiguration(title: playlist.title, artwork: playlist.artwork)
                    cell.contentConfiguration = config
                }
                
                cell.accessoryType = viewModel.isSelected(id) ? .checkmark : .none
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
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.applyTableSelections(items: newRender.items)
        }
    }
    
    /// Make table view selections match checkmarks
    private func applyTableSelections(items: [Item]) {
        for item in items {
            guard case .playlist(let id) = item else { continue }
            guard let indexPath = dataSource.indexPath(for: item) else { continue }

            if viewModel.isSelected(id) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    @objc
    func didTapAdd() {
        viewModel.saveSelections()
    }
}

extension RemotePlaylistsSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if case .playlist(let id) = item {
            viewModel.setSelection(true, for: id)
            
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems([item])
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if case .playlist(let id) = item {
            viewModel.setSelection(false, for: id)
            
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems([item])
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    // TODO: UITableViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.fetchNextPageIfNeeded(currentIndex: indexPath.row)
    }
}
