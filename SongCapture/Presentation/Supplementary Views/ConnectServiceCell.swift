//
//  ConnectServiceCell.swift
//  SongCapture
//
//  Created by John Jones on 1/11/26.
//

import UIKit

final class ConnectServiceCell: UITableViewCell {
    static let reuseIdentifier = "ConnectServiceCell"

    private let normalColor: UIColor = .secondarySystemBackground
    private let highlightedColor: UIColor = .tertiarySystemBackground

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .default
        backgroundColor = .clear
        contentView.backgroundColor = normalColor
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.layer.borderWidth = 0.5

        configurationUpdateHandler = { [weak self] cell, state in
            guard let self = self else { return }
            let isHighlighted = state.isHighlighted || state.isSelected
            self.contentView.backgroundColor = isHighlighted ? self.highlightedColor : self.normalColor
            UIView.animate(withDuration: 0.15) {
                cell.transform = isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }

    func configure(title: String, image: UIImage?) {
        var config = defaultContentConfiguration()
        config.text = title
        config.image = image
        config.imageProperties.maximumSize = CGSize(width: 65, height: 65)
        config.imageProperties.reservedLayoutSize = CGSize(width: 65, height: 65)
        config.imageProperties.preferredSymbolConfiguration = .init(pointSize: 48, weight: .regular)
        config.textProperties.font = .preferredFont(forTextStyle: .headline)
        contentConfiguration = config
    }
}
