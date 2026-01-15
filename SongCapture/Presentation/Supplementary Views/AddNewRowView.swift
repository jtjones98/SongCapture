//
//  AddNewRowView.swift
//  SongCapture
//
//  Created by John Jones on 1/15/26.
//

import UIKit
// MARK: - Reusable AddNewRowView

final class AddNewRowView: UIView {
    private let contentView = PlaylistRowContentView(configuration: PlaylistRowConfiguration(title: "", subtitle: nil, image: nil))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }

    private func setup() {
        backgroundColor = .clear
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(title: String) {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)
        let configuration = PlaylistRowConfiguration(title: title, subtitle: nil, image: image)
        contentView.configuration = configuration
        accessibilityLabel = title
    }

    func prepareForReuse() {
        let configuration = PlaylistRowConfiguration(title: "", subtitle: nil, image: nil)
        contentView.configuration = configuration
        accessibilityLabel = nil
    }
}

// MARK: - UITableViewCell wrapper

final class AddNewRowTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AddNewRowTableViewCell"

    private let rowView = AddNewRowView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }

    private func setup() {
        selectionStyle = .default
        contentView.addSubview(rowView)
        rowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        // Ensure proper background for grouped/list appearances
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        accessoryType = .disclosureIndicator
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rowView.prepareForReuse()
    }

    func configure(title: String) {
        rowView.configure(title: title)
    }
}

// MARK: - UICollectionViewCell wrapper

final class AddNewRowCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "AddNewRowCollectionViewCell"

    private let rowView = AddNewRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }

    private func setup() {
        contentView.addSubview(rowView)
        rowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rowView.prepareForReuse()
    }

    func configure(title: String) {
        rowView.configure(title: title)
    }
}

