//
//  NewEditGroupViewController.swift
//  SongCapture
//
//  Created by John Jones on 1/9/26.
//

import UIKit

fileprivate typealias Section = NewEditGroupViewModel.Section
fileprivate typealias Item = NewEditGroupViewModel.Item
fileprivate typealias DataSource = UITableViewDiffableDataSource<Section, Item>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

class NewEditGroupViewController: UIViewController {
    
    private var viewModel: NewEditGroupViewModel
    private weak var coordinator: PlaylistsAndGroupsCoordinating?
    
    private var tableView: UITableView!
    private var dataSource: DataSource!
    
    init(with viewModel: NewEditGroupViewModel, coordinator: PlaylistsAndGroupsCoordinating) {
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
        configureTableView()
        configureDataSource()
        
        viewModel.getPlaylists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("willAppear title:", navigationItem.title as Any, "titleView:", navigationItem.titleView as Any)
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
            case .error(let error):
                switch error {
                case .authFailure(let title, let body, let action):
                    self?.presentAuthFailureAlert(title: title, message: body, actionTitle: action)
                }
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
        tableView.register(EmptyPlaylistsCell.self, forCellReuseIdentifier: EmptyPlaylistsCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
            case .empty:
                return tableView.dequeueReusableCell(withIdentifier: EmptyPlaylistsCell.reuseIdentifier, for: indexPath) as? EmptyPlaylistsCell
            }
        }
    }
    
    private func applySnapshot(render: NewEditGroupViewModel.RenderModel) {
        var snapshot = Snapshot()
        snapshot.appendSections(render.sections)
        
        for section in render.sections {
            let items = render.itemsBySection[section] ?? []
            snapshot.appendItems(items, toSection: section)
        }
        
        // If the section structure changed, reload instead of animating.
        let oldSections = dataSource.snapshot().sectionIdentifiers
        let newSections = snapshot.sectionIdentifiers
        let sectionStructureChanged = oldSections != newSections

        if sectionStructureChanged {
            dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        //dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func footerButtonTapped() {
        goToNewScreen()
    }

    private func goToNewScreen() {
        // Placeholder destination; replace with your actual view controller as needed
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Next Screen"
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
    
    private func presentAuthFailureAlert(title: String, message: String, actionTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actionTitle, !actionTitle.isEmpty {
            let settingsAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(settingsAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension NewEditGroupViewController: UITableViewDelegate {
    
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
        case .service(let service):
            return viewAllPlaylistsFooterView(service: service, title: section.footerTitle)
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = dataSource.snapshot().sectionIdentifiers[section]
        switch section {
        case .service(_):
            return 56
        default:
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = dataSource.itemIdentifier(for: indexPath)
        if case .grantAccess(let service) = item {
            viewModel.requestMusicAuthorization(for: service)
        }
    }
    
    private func viewAllPlaylistsFooterView(service: Service, title: String) -> UITableViewHeaderFooterView {
        let footer = UITableViewHeaderFooterView()
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewAllPlaylistsTapped(service: service)
        }), for: .touchUpInside)
                
        footer.contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: footer.contentView.topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: footer.contentView.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: footer.contentView.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: footer.contentView.bottomAnchor, constant: -8)
        ])
        
        return footer
    }
    
    private func viewAllPlaylistsTapped(service: Service) {
        coordinator?.showPlaylists()
    }
}

