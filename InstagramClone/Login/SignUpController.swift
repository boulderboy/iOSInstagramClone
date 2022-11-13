//
//  ViewController.swift
//  InstagramClone
//
//  Created by КИМ on 18.10.2022.
//

import UIKit
import Firebase
import FirebaseStorage

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)

        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        dismiss(animated: true)
    }
    
    let emailTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Email"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(handleTextInput(sender:)), for: .editingChanged)
        return textField
    }()
    
    @objc func handleTextInput(sender: UITextField) {
        let isFormValid = Validators.isValidEmail(emailTextField.text ?? "")
                            && usernameTextField.text?.count ?? 0 > 0
                            && passwordTextField.text?.count ?? 0 >= 6
        if isFormValid {
            signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            signUpButton.isEnabled = true
        } else {
            signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            signUpButton.isEnabled = false
        }
    }
    
    let usernameTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "User"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(handleTextInput(sender:)), for: .editingChanged)
        return textField
    }()
    
    let passwordTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(handleTextInput(sender:)), for: .editingChanged)
        return textField
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else {return}
        guard let userName = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
    
        
        Auth.auth().createUser(withEmail: email, password: password) {(user: AuthDataResult?, error: Error?) in
            if let error = error {
                print("failed", error)
                return
            }
            print("success")

            guard let image = self.plusPhotoButton.imageView?.image else { return }
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            let filename = NSUUID().uuidString


            let profileImageRef = Storage.storage().reference().child("profile_image").child(filename)
            profileImageRef.putData(uploadData, completion: {(metadata, err) in
                if let err = err {
                    print("Error", err)
                    return
                }
                print("succesfully")

                profileImageRef.downloadURL { (url, error) in
                    guard
                        let userImageURL = url?.absoluteString,
                        let uid = user?.user.uid
                    else {
                        return
                    }

                    let userNameValeues  = [
                        "username": userName,
                        "userImage" : userImageURL
                    ]

                    let values = [uid: userNameValeues]

                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: {(err, ref) in
                        if let err = err {
                            print("Failed", err)
                        }
                        print("Succes import", uid)
                        
                        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                        
                        mainTabBarController.setupViewControllers()
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            })
        }

    }
    
    let alreadyHaveAnAccountButtton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Login.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setTitle("Don't have an account? Sign Up.", for: .normal)
        button.addTarget(self, action: #selector(handlerAlreadyHaveAnAccount), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func handlerAlreadyHaveAnAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        setupInputFields()
        view.addSubview(alreadyHaveAnAccountButtton)
        
        NSLayoutConstraint.activate([
            plusPhotoButton.heightAnchor.constraint(equalToConstant: 140),
            plusPhotoButton.widthAnchor.constraint(equalToConstant: 140),
            plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            alreadyHaveAnAccountButtton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alreadyHaveAnAccountButtton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            alreadyHaveAnAccountButtton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alreadyHaveAnAccountButtton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.axis = .vertical
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: plusPhotoButton.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
}

