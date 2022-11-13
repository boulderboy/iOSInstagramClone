//
//  UserSearchCell.swift
//  InstagramClone
//
//  Created by Mac on 12.11.2022.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    
    enum Constants {
        static let profileImageWiewHeigh = 50.0
    }
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
             
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Constants.profileImageWiewHeigh  / 2
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let separatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5 )
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageWiewHeigh),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageWiewHeigh),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: topAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor,constant: 8),
            usernameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
