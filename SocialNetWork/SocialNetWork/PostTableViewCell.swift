//
//  PostTableViewCell.swift
//  SocialNetWork
//
//  Created by Алеся Афанасенкова on 10.03.2025.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [avatarImageView, titleLabel, bodyLabel].forEach { addSubview($0) }
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with model: PostModel) {
        titleLabel.text = model.title
        bodyLabel.text = model.body
        if let avatarURL = model.avatarURL {
            ImageLoader.shared.loadImage(from: avatarURL) { image in
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                }
            }
        }
    }
}
