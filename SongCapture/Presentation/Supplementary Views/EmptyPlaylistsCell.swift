//
//  EmptyPlaylistsCell.swift
//  SongCapture
//
//  Created by John Jones on 1/13/26.
//

import UIKit

final class EmptyPlaylistsCell: UITableViewCell {
    static let reuseIdentifier = "EmptyPlaylistsCell"
    
    private let normalColor: UIColor = .systemBackground

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = normalColor
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.layer.borderWidth = 0.5
        
        var config = defaultContentConfiguration()
        config.text = "No playlists added"
        config.textProperties.color = .secondaryLabel
        config.textProperties.alignment = .center
        contentConfiguration = config
    }
}
