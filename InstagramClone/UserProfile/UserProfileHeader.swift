//
//  UserProfileHeader.swift
//  InstagramClone
//
//  Created by КИМ on 20.10.2022.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    enum Constants {
        static let databseFollowingChild = "following"
        static let followButtonBlueColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        static let unfollowText = "Unfollow"
        static let followText = "Follow"
    }
    
    var user: User? {
        didSet {
            guard let profleImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profleImageUrl)

            usernameLabel.text = user?.username
            
            setupEditFollowButton()
        }
    }
    
    let profileImageView: CustomImageView = {
       let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
    //    button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let folowersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "folowers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let folowingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "folowing", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileButtonOrFollow), for: .touchUpInside)
        return button
    }()
    
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            profileImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.layer.masksToBounds = true
        
        setupButtonToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            usernameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            usernameLabel.bottomAnchor.constraint(equalTo: gridButton.topAnchor)
        ])
        
        setupUserStatsView()
    }
    
    fileprivate func  setupEditFollowButton() {
        guard let currentUserLoggedInUid = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentUserLoggedInUid == userId {
            
        } else {
            
            Database.database().reference().child(Constants.databseFollowingChild).child(currentUserLoggedInUid).child(userId).observeSingleEvent(of: .value) { snapshot in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1  {
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                } else {
                    self.setupFollowStyle()
                }
            }
            
           
        }
    }
    
    @objc fileprivate func handleEditProfileButtonOrFollow() {
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }

        if editProfileFollowButton.titleLabel?.text == Constants.unfollowText {
             
            Database.database().reference().child(Constants.databseFollowingChild).child(currentLoggedInUserId).child(userId).removeValue(completionBlock: {(err, ref) in
                if let err = err {
                    print("error of unfollowing", err)
                    return
                }
                print("succesfully unfolowed",  self.user?.username ?? "")
                self.setupFollowStyle()
            })
            
        } else {
            let ref = Database.database().reference().child(Constants.databseFollowingChild).child(currentLoggedInUserId)
            
            let values = [userId: 1]
            ref.updateChildValues(values) { (_, ref) in
                print("succesfully followed ")
                self.editProfileFollowButton.setTitle(Constants.unfollowText, for: .normal)
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle(Constants.followText, for: .normal)
        self.editProfileFollowButton.backgroundColor = Constants.followButtonBlueColor
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
    }
    
    fileprivate func setupUserStatsView() {
        
        let stackView = UIStackView(arrangedSubviews: [postsLabel, folowersLabel, folowingLabel])
        addSubview(stackView)
        addSubview(editProfileFollowButton)
        
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        editProfileFollowButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:  -12),
            stackView.heightAnchor.constraint(equalToConstant: 50),

            editProfileFollowButton.topAnchor.constraint(equalTo: postsLabel.bottomAnchor, constant: 8),
            editProfileFollowButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            editProfileFollowButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            editProfileFollowButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        
    }
    
    fileprivate func setupButtonToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        topDividerView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        bottomDividerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            
            topDividerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            topDividerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            topDividerView.topAnchor.constraint(equalTo: stackView.topAnchor),
            topDividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            bottomDividerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomDividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomDividerView.topAnchor.constraint(equalTo: self.bottomAnchor),
            bottomDividerView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
