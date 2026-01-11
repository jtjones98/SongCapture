//
//  NewGroupViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/9/26.
//

import UIKit

fileprivate typealias Section = NewGroupViewModel.Section
fileprivate typealias Item = NewGroupViewModel.Item
fileprivate typealias DataSource = UITableViewDiffableDataSource<Section, Item>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

class NewGroupViewController: UIViewController {
    
    private var viewModel: NewGroupViewModel
    private weak var coordinator: PlaylistGroupsCoordinating?
    
    private var tableView: UITableView!
    private var dataSource: DataSource!
    private var appleMusicButton: UIButton!
    private var spotifyButton: UIButton!
    
    init(with viewModel: NewGroupViewModel, coordinator: PlaylistGroupsCoordinating) {
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
        
        navigationItem.title = "New Group"
        
        configureViewModel()
        configureTableView()
        configureDataSource()
        
        viewModel.getPlaylists()
    }
    
    private func configureViewModel() {
        viewModel.onStateChange = { [weak self] state in
            switch state {
            case .idle:
                break
            case .loading:
                // TODO: loading
                break
            case .loaded(let renderModel):
                // TODO: handle dictionary or something
                self?.applySnapshot(render: renderModel)
            case .error(let message):
                // TODO: handle error
                break
            }
        }
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.allowsMultipleSelection = true
        
        tableView.delegate = self
        
        // Register cell and section header
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ConnectServiceCell.self, forCellReuseIdentifier: ConnectServiceCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .playlist(let playlist):
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                var config = cell.defaultContentConfiguration()
                config.text = playlist.name
                cell.contentConfiguration = config
                return cell
            case .grantAccess(let service):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ConnectServiceCell.reuseIdentifier, for: indexPath) as? ConnectServiceCell else {
                    return UITableViewCell()
                }
                cell.configure(title: service.title, image: UIImage(named: service.imageName))
                return cell
            }
        }
    }
    
    private func applySnapshot(render: NewGroupViewModel.RenderModel) {
        var snapshot = Snapshot()
        snapshot.appendSections(render.sections)
        
        for section in render.sections {
            let items = render.itemsBySection[section] ?? []
            snapshot.appendItems(items, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension NewGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = dataSource.snapshot().sectionIdentifiers[section]
        switch section {
        case .service(let service):
            let header = UITableViewHeaderFooterView()
            var config = header.defaultContentConfiguration()
            config.text = service.title
            config.image = UIImage(named: service.imageName)
            config.imageProperties.maximumSize = CGSize(width: 30, height: 30)
            header.contentConfiguration = config
            return header
        case .grantAccess:
            let header = UITableViewHeaderFooterView()
            var config = header.defaultContentConfiguration()
            config.text = section.title
            header.contentConfiguration = config
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let section = dataSource.snapshot().sectionIdentifiers[section]
        switch section {
        case .service:
            let footer = UITableViewHeaderFooterView()
            var config = footer.defaultContentConfiguration()
            config.text = section.footerTitle
            footer.contentConfiguration = config
            return footer
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


