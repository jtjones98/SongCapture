//
//  PlaylistRowContentView.swift
//  SongCapture
//
//  Created by John Jones on 1/14/26.
//

import UIKit

struct PlaylistRowConfiguration: UIContentConfiguration {
    let title: String
    let subtitle: String?
    let image: UIImage?
    
    func makeContentView() -> any UIView & UIContentView {
        PlaylistRowContentView(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> PlaylistRowConfiguration {
        // TODO: selected/highlighted styling later, inspect `state` here.
        self
    }
}

final class PlaylistRowContentView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfig = newValue as? PlaylistRowConfiguration else { return }
            apply(newConfig)
        }
    }
    
    private var currentConfiguration: PlaylistRowConfiguration
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()
    
    init(configuration: PlaylistRowConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = true
        setup()
        apply(configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }
    
    private func setup() {
        // Configure subviews
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .tertiarySystemFill

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 1
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.numberOfLines = 1
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        let contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        var constraints: [NSLayoutConstraint] = []

        constraints += [
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.leading),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: contentInsets.top),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -contentInsets.bottom),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 56),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.trailing),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ]
        
        // "The labels drive the cell's height"
        // Bottom anchoring to avoid ambiguous height:
        // 1) If subtitle is present, it should pin the bottom.
        // 2) If subtitle is absent, allow the title to pin the bottom as a fallback.
        let subtitleTop = subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        let subtitleBottom = subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
        let titleBottomFallback = titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
        subtitleTop.priority = .defaultHigh
        subtitleBottom.priority = .required
        titleBottomFallback.priority = .defaultLow

        constraints += [
            subtitleTop,
            subtitleBottom,
            titleBottomFallback
        ]
        
        // Ensure the content view is at least as tall as the image + insets
        let minHeight = heightAnchor.constraint(greaterThanOrEqualToConstant: 56 + contentInsets.top + contentInsets.bottom)
        minHeight.priority = .required
        constraints += [minHeight]

        NSLayoutConstraint.activate(constraints)
    }
    
    private func apply(_ config: PlaylistRowConfiguration) {
        currentConfiguration = config
        titleLabel.text = config.title
        subtitleLabel.text = config.subtitle
        imageView.image = config.image
    }
    
    // TODO: Prepare for reuse
}

