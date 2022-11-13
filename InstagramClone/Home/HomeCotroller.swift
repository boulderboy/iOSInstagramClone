//
//  HomeCotroller.swift
//  InstagramClone
//
//  Created by КИМ on 26.10.2022.
//

import UIKit
import Firebase



class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    enum Constants {
        static let databseFollowingChild = "following"
        static let cellId = "cellId"
        static let updateFeedNotificationName = "UpdateFeed"
        static let cameraButtonImageName = "camera3"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = NSNotification.Name(rawValue: Constants.updateFeedNotificationName )
        NotificationCenter.default.addObserver( self, selector: #selector(handleUpdateFeed), name: name , object: nil)
        
        collectionView.backgroundColor = .white
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: Constants.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        setUpNavigationItems()
        fetchAllPosts()
    }
    
    @objc fileprivate func handleUpdateFeed() {
        posts.removeAll()
        handleRefresh()
    }
    
    @objc fileprivate func handleRefresh() {
        print("refreshed")
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUsersIds()
    }
    
    fileprivate func fetchFollowingUsersIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child(Constants.databseFollowingChild).child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            userIdsDictionary.forEach { key, value in
                Database.fetchUserWithUid(uid: key) { user in
                    self.fetchPostsWithUser(user: user)
                }
            }
        }
    }
    
    var posts = [Post]()
    
    fileprivate func fetchPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUid(uid: uid) {user in
            self.fetchPostsWithUser(user: user)
        }
      
    }
    
    fileprivate func fetchPostsWithUser(user: User) {

        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value){ snapshot,err   in
            self.collectionView.refreshControl?.endRefreshing()
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach { (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let imageUrl = dictionary["imageUrl"] as? String
                let post = Post(user: user, dictionary: dictionary)
                self.posts.append(post)
            }
            
            self.posts.sort { p1, p2 in
                return p1.creationDate > p2.creationDate
            }
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func setUpNavigationItems() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: Constants.cameraButtonImageName)?.withRenderingMode(.alwaysOriginal ), style: .plain , target: self, action: #selector(handleCameraButton) )
    }
    
    @objc fileprivate func handleCameraButton() {
        print("showing camera")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 16
        height += view.frame.width
        height += 50
        height += 50
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
}
