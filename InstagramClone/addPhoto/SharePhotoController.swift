//
//  SharePhotoController.swift
//  InstagramClone
//
//  Created by КИМ on 24.10.2022.
//

import UIKit
import Firebase
import FirebaseStorage

class SharePhotoController: UIViewController {
    
    enum Constants {
        static let updateFeedNotificationName = "UpdateFeed"
    }
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain,target: self, action: #selector(sharePhoto))
        
        setUpImageAndText()
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .cyan
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    fileprivate func setUpImageAndText() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
  
        containerView.addSubview(imageView)
        containerView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 84),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    @objc func sharePhoto() {
        guard let image = selectedImage else { return }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        let filename = NSUUID().uuidString
        
        let sharedImageRef = Storage.storage().reference().child("posts").child(filename)
        sharedImageRef.putData(uploadData) { (metadeta, err) in
            if let err = err {
                print("Failed upload image", err)
                return
            }
    
            sharedImageRef.downloadURL(completion: {(url, err) in
                if err != nil { return }
                guard let url = url?.absoluteString else { return }
                print("successfuly download", url)
                self.saveToDatabaseWithUrl(imageUrl: url)
            })
        }
    }
    
    fileprivate func saveToDatabaseWithUrl(imageUrl: String) {
        guard let postedImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostsRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostsRef.childByAutoId()
        let values = [
            "imageUrl": imageUrl,
            "caption": caption,
            "imageWidth": postedImage.size.width,
            "imageHeight": postedImage.size.height,
            "creationDate": Date().timeIntervalSince1970
        ] as [String : Any]
        ref.updateChildValues(values) {(err, ref) in
            if let err = err {
                print("failed to save post", err)
            }
            
            print("successfully saved post to db")
            self.dismiss(animated: true)
            
            let name = NSNotification.Name(rawValue: Constants.updateFeedNotificationName)
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
