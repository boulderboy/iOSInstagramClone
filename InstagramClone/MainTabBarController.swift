//
//  MainTabBarController.swift
//  InstagramClone
//
//  Created by КИМ on 19.10.2022.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectionController = PhotoSelectionController(collectionViewLayout: layout)
            let navContoller = UINavigationController(rootViewController: photoSelectionController)
            present(navContoller, animated: true)
            return false
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: false)
            }
            
            return
        }
        
        setupViewControllers()
       
    }
    
    func setupViewControllers() {
        
        let homeNavController = templateNavController(unselectedImage: UIImage(named: "home_unselected"), selectedImage: UIImage(named: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        let searchNavController = templateNavController(unselectedImage: UIImage(named: "search_unselected"), selectedImage: UIImage(named: "search_selected"), rootViewController: UserSearchController(collectionViewLayout:  UICollectionViewFlowLayout()))
        
        let plusNavController = templateNavController(unselectedImage: UIImage(named: "plus_unselected"), selectedImage: UIImage(named: "plus_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let likeNavController = templateNavController(unselectedImage: UIImage(named: "like_unselected"), selectedImage: UIImage(named: "like_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let userNavController = UINavigationController(rootViewController: userProfileController)
        
        userNavController.tabBarItem.image = UIImage(named: "profile_unselected")
        userNavController.tabBarItem.selectedImage = UIImage(named: "profile_selected")
        
        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
        
        
        viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userNavController]
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage?, selectedImage: UIImage?, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        
        return navController
    }
    
}

