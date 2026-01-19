//
//  PlaylistRowContentView.swift
//  SongCapture
//
//  Created by John Jones on 1/14/26.
//

import MusicKit
import SwiftUI
import UIKit

struct PlaylistRowConfiguration: UIContentConfiguration {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let artwork: PlaylistArtwork?
    var useHosting: Bool {
        switch artwork {
        case .appleMusic: return true
        default: return false
        }
    }
    
    init(title: String, subtitle: String? = nil, image: UIImage? = nil, artwork: PlaylistArtwork? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.artwork = artwork
    }
    
    func makeContentView() -> any UIView & UIContentView {
        PlaylistRowContentView(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> PlaylistRowConfiguration {
        // TODO: selected/highlighted styling later, inspect `state` here.
        self
    }
}

final class PlaylistRowContentView: UIView, UIContentView {
    
    // TODO: We could do this differently
    static var imageLoader: ImageLoading?
    
    private var hostingController: UIHostingController<ArtworkThumbnailView>?
    
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
    
    private func ensureHostingView() {
        guard hostingController == nil else { return }
        let hc = UIHostingController(rootView: ArtworkThumbnailView(artwork: nil, size: 56))
        hostingController = hc
        hc.view.backgroundColor = .clear
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hc.view)
    }
    
    private func setup() {
        // Configure subviews
        let hc = UIHostingController(rootView: ArtworkThumbnailView(artwork: nil, size: 56))
        hostingController = hc
        hc.view.backgroundColor = .clear
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hc.view)
        
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
            // Shared frame for artwork views (hosting and imageView)
            hc.view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.leading),
            hc.view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: contentInsets.top),
            hc.view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -contentInsets.bottom),
            hc.view.centerYAnchor.constraint(equalTo: centerYAnchor),
            hc.view.widthAnchor.constraint(equalToConstant: 56),
            hc.view.heightAnchor.constraint(equalToConstant: 56),

            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.leading),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: contentInsets.top),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -contentInsets.bottom),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
            titleLabel.leadingAnchor.constraint(equalTo: hc.view.trailingAnchor, constant: 12),
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
        print("jtj applying config for \(config.title)")
        
        currentConfiguration = config
        titleLabel.text = config.title
        subtitleLabel.text = config.subtitle
        
        // Toggle which artwork view is visible
        hostingController?.view.isHidden = !config.useHosting
        imageView.isHidden = config.useHosting
        
        // If config has image (such as the case of image given to add new playlist row) use this image instead of url
        if let image = config.image {
            self.imageView.image = image
            return
        }
        
        // Update SwiftUI artwork thumbnail when using hosting
        if let hostingController {
            let appleArtwork: MusicKit.Artwork?
            switch config.artwork {
            case .appleMusic(let art):
                appleArtwork = art
            default:
                appleArtwork = nil
            }
            hostingController.rootView = ArtworkThumbnailView(artwork: appleArtwork, size: 56)
        }
    }
    
    deinit {
        print("JTJ deinit contentView for title:", currentConfiguration.title)
    }
    
    // TODO: Prepare for reuse
}

