//
//  SectionHeaderView.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

import UIKit

/// A reusable section header for table views and collection views
final class SectionHeaderView: UIView {
    private let label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = .preferredFont(forTextStyle: .headline)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }
    
    func configure(title: String) {
        label.text = title
    }
    
    func prepareForReuse() {
        label.text = nil
    }
}

// MARK: TableView wrapper
final class TableSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseID = "TableSectionHeader"
    private let titleView = SectionHeaderView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleView.prepareForReuse()
    }
    
    func configure(title: String) {
        titleView.configure(title: title)
    }
}

// MARK: CollectionView wrapper

final class CollectionSectionHeader: UICollectionReusableView {
    static let reuseID = "CollectionSectionHeader"
    private let titleView = SectionHeaderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleView.topAnchor.constraint(equalTo: topAnchor),
            titleView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleView.prepareForReuse()
    }
    
    func configure(title: String) {
        titleView.configure(title: title)
    }
}
