//
//  LoginVC.swift
//  FirebaseChat
//
//  Created by Ajo M Varghese on 13/11/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK : - Declaration
    lazy var profileImageView: UIImageView = {
        let imgView = UIImageView();
        imgView.contentMode = .scaleAspectFill;
        imgView.image = UIImage(named: "person");
        let tap = UITapGestureRecognizer();
        tap.numberOfTapsRequired = 1;
        tap.addTarget(self, action: #selector(selectProfilePicture));
        imgView.addGestureRecognizer(tap);
        imgView.isUserInteractionEnabled = true;
        imgView.translatesAutoresizingMaskIntoConstraints = false;
        return imgView;
    }();
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.tintColor = .white;
        sc.selectedSegmentIndex = 1;
        sc.addTarget(self, action: #selector(toggleLoginAndRegister), for: UIControl.Event.valueChanged);
        sc.translatesAutoresizingMaskIntoConstraints = false;
        return sc;
    }();
    
    let inputsContainerView: UIView = {
        let containerView = UIView();
        containerView.backgroundColor = .white;
        containerView.layer.cornerRadius = 5;
        containerView.layer.masksToBounds = true;
        containerView.translatesAutoresizingMaskIntoConstraints = false;
        return containerView;
    }();
    
    lazy var registerButton: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.system);
        btn.setTitle("Register", for: UIControl.State.normal);
        btn.backgroundColor = UIColor(r: 80, g: 101, b: 161);
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16);
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal);
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = true;
        btn.addTarget(self, action: #selector(registerButtonPressed), for: UIControl.Event.touchUpInside);
        btn.translatesAutoresizingMaskIntoConstraints = false;
        return btn;
    }();
    
    let nameTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Name";
        tf.keyboardType = .alphabet;
        tf.autocapitalizationType = .words;
        tf.translatesAutoresizingMaskIntoConstraints = false;
        return tf;
    }();
    
    let nameSeperatorLine: UIView = {
        let seperatorLine = UIView();
        seperatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220);
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false;
        return seperatorLine;
    }();
    
    let emailTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Email ID";
        tf.keyboardType = .emailAddress;
        tf.autocapitalizationType = .none;
        tf.translatesAutoresizingMaskIntoConstraints = false;
        return tf;
    }();
    
    let emailSeperatorLine: UIView = {
        let seperatorLine = UIView();
        seperatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220);
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false;
        return seperatorLine;
    }();
    
    let passwordTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Password";
        tf.returnKeyType = .go;
        tf.isSecureTextEntry = true;
        tf.translatesAutoresizingMaskIntoConstraints = false;
        return tf;
    }();
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    var mainVC: MainVC?
    
    // MARK : - Actions
    @objc func selectProfilePicture() {
        let picker = UIImagePickerController();
        picker.delegate = self;
        picker.allowsEditing = true;
        
        present(picker, animated: true, completion: nil);
    }
    
    @objc func toggleLoginAndRegister() {
        /* change the button name */
        let buttonTitle = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex);
        registerButton.setTitle(buttonTitle, for: UIControl.State.normal);
        
        /* change the size of container view */
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150;
        
        /* remove name text field */
        nameTextFieldHeightAnchor?.isActive = false;
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3);
        nameTextFieldHeightAnchor?.isActive = true;
        
        /* change email text field height */
        emailTextFieldHeightAnchor?.isActive = false;
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3);
        emailTextFieldHeightAnchor?.isActive = true;
        
        /* change password text field height */
        passwordTextFieldHeightAnchor?.isActive = false;
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3);
        passwordTextFieldHeightAnchor?.isActive = true;
    }
    
    @objc func registerButtonPressed() {
        loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? handleLogin() : handleRegister();
    }
    
    @objc func handleRegister() {
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            return;
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (userData, error) in
            if error != nil {
                print("Error creating user: \(error.debugDescription)");
                return;
            }
            /* successfully registered user */
            guard let uid = userData?.user.uid else {
                return;
            }
            
            let imageName = UUID().uuidString;
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg");
            guard let profileImage = self.profileImageView.image else {
                return;
            }
            if let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil, metadata != nil {
                        print(error ?? "");
                        return;
                    }
                    storageRef.downloadURL(completion: { (url, err) in
                        if err != nil {
                            print(err.debugDescription);
                            return;
                        }
                        if let profileImageUrl = url?.absoluteString {
                            let values = ["name": name,
                                          "email": email,
                                          "profile_image": profileImageUrl];
                            self.registerUserIntoDatabaseWith(uid: uid, values: values as [String: AnyObject]);
                        }
                    });
                });
            }
        }
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return;
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (userData, error) in
            if error != nil {
                print(error.debugDescription);
                return;
            }
            /* successfully logged in */
            self.mainVC?.setupNavbarTitle();
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    // MARK : - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad();
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151);
        
        setupViews();
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    // MARK : - Setup UI
    func setupViews() {
        view.addSubview(profileImageView);
        view.addSubview(loginRegisterSegmentedControl);
        view.addSubview(inputsContainerView);
        view.addSubview(registerButton);
        
        /* Profile Image */
        NSLayoutConstraint.activate([profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12),
                                     profileImageView.widthAnchor.constraint(equalToConstant: 150),
                                     profileImageView.heightAnchor.constraint(equalToConstant: 150)]);
        /* segmented Control */
        NSLayoutConstraint.activate([loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12),
                                     loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1),
                                     loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36)]);
        /* Container View */
        NSLayoutConstraint.activate([inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24)]);
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150);
        inputsContainerViewHeightAnchor?.isActive = true;
        /* Register button */
        NSLayoutConstraint.activate([registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     registerButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12),
                                     registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
                                     registerButton.heightAnchor.constraint(equalToConstant: 50)]);
        
        setupContainerView();
    }
    
    func setupContainerView() {
        inputsContainerView.addSubview(nameTextField);
        inputsContainerView.addSubview(nameSeperatorLine);
        inputsContainerView.addSubview(emailTextField);
        inputsContainerView.addSubview(emailSeperatorLine);
        inputsContainerView.addSubview(passwordTextField);
        
        /* name text field */
        NSLayoutConstraint.activate([nameTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12),
                                     nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor),
                                     nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor)]);
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3);
        nameTextFieldHeightAnchor?.isActive = true;
        /* name seperator line */
        NSLayoutConstraint.activate([nameSeperatorLine.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor),
                                     nameSeperatorLine.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
                                     nameSeperatorLine.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
                                     nameSeperatorLine.heightAnchor.constraint(equalToConstant: 1)]);
        /* email text field */
        NSLayoutConstraint.activate([emailTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12),
                                     emailTextField.topAnchor.constraint(equalTo: nameSeperatorLine.bottomAnchor),
                                     emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor)]);
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3);
        emailTextFieldHeightAnchor?.isActive = true;
        /* email seperator line */
        NSLayoutConstraint.activate([emailSeperatorLine.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor),
                                     emailSeperatorLine.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
                                     emailSeperatorLine.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
                                     emailSeperatorLine.heightAnchor.constraint(equalToConstant: 1)]);
        /* password text field */
        NSLayoutConstraint.activate([passwordTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12),
                                     passwordTextField.topAnchor.constraint(equalTo: emailSeperatorLine.bottomAnchor),
                                     passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor)]);
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3);
        passwordTextFieldHeightAnchor?.isActive = true;
    }
    
    // MARK : - Delegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError();
        }
        profileImageView.image = editedImage;
        
        dismiss(animated: true, completion: nil);
    }
    
    // MARK : - Custom Methods
    private func registerUserIntoDatabaseWith(uid: String, values: [String: AnyObject]) {
        let dbRef = Database.database().reference();
        let userReference = dbRef.child("users").child(uid);
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!);
                return;
            }
            self.mainVC?.navigationItem.title = values["name"] as? String;
            self.dismiss(animated: true, completion: nil);
        });
    }
    
} // Class
