//
//  PlaylistCell.swift
//  SongCapture
//
//  Created by John Jones on 1/14/26.
//


import UIKit

final class PlaylistCell: UICollectionViewCell {
    static let reuseIdentifier = "PlaylistCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentConfiguration = nil
    }
    
    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
    }
    
    func configure(title: String, subtitle: String?, image: UIImage?) {
        var config = UIListContentConfiguration.subtitleCell()
        config.text = title
        config.secondaryText = subtitle
        config.image = image
        config.imageProperties.maximumSize = CGSize(width: 56, height: 56)
        config.imageProperties.reservedLayoutSize = CGSize(width: 56, height: 56)
        config.imageProperties.preferredSymbolConfiguration = .init(pointSize: 40, weight: .regular)
        config.textProperties.font = .preferredFont(forTextStyle: .headline)
        config.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
        self.contentConfiguration = config
    }
}

