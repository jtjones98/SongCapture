//
//  AddNewGroupCell.swift
//  SongCapture
//
//  Created by John Jones on 1/7/26.
//

import UIKit

final class AddNewGroupCell: UICollectionViewCell {
    static let reuseIdentifier = "AddNewGroupCell"
    
    private var containerView: UIView!
    private var plusImageView: UIImageView!
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("From coder not implemented")
    }
    
    private func setupUI() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.6)

        plusImageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.contentMode = .scaleAspectFit
        plusImageView.tintColor = .systemBlue

        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Add New Group"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .systemBlue
        titleLabel.textAlignment = .center

        contentView.addSubview(containerView)
        containerView.addSubview(plusImageView)
        containerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            plusImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -8),
            plusImageView.heightAnchor.constraint(equalToConstant: 32),
            plusImageView.widthAnchor.constraint(equalTo: plusImageView.heightAnchor),

            titleLabel.topAnchor.constraint(equalTo: plusImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])

        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
    }
    
    func configure(title: String? = nil, tintColor: UIColor = .systemBlue) {
        titleLabel.text = title ?? "Add New Group"
        titleLabel.textColor = tintColor
        plusImageView.tintColor = tintColor
    }
}
