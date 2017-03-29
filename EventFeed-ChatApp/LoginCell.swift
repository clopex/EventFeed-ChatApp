//
//  LoginCell.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/21/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit

class LoginCell: UICollectionViewCell {
    
    var verticalPageControllerConstraint: NSLayoutConstraint?
    var bottomViewHeightConstraint: NSLayoutConstraint?
    var signUpConstraint: NSLayoutConstraint?
    
    let bottomView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.rgb(red: 88, green: 143, blue: 251)
        return view
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        //button.addTextSpacing(spacing: 1)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11) //UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(loginFunctionButton), for: .touchUpInside)
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Signup", for: .normal)
        //button.addTextSpacing(spacing: 1)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13) //UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(signupFunctionButton), for: .touchUpInside)
        return button
    }()
    
    var isSignupViewOpen = false
    var isLoginViewOpen = false
    var isReadyForLogin = false
    
    weak var delegate: LoginControllerDelegate?
    
    func animationLayoutIfNeeded() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .transitionCurlUp, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }

    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "profile")
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let backgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "wall")
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Profile"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.rgb(red: 88, green: 143, blue: 251)
        return label
    }()
    
    let centerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.alpha = 0
        view.backgroundColor = UIColor.rgb(red: 88, green: 143, blue: 251)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let nameTextField: UITextField = {
        let text = UITextField()
        //text.placeholder = "Name"
        text.textColor = .white
        text.attributedPlaceholder = NSMutableAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName: UIColor.white])
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let passwordTextField: UITextField = {
        let text = UITextField()
        text.attributedPlaceholder = NSMutableAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.white])
        text.isSecureTextEntry = true
        text.textColor = .white
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let emailTextField: UITextField = {
        let text = UITextField()
        text.attributedPlaceholder = NSMutableAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.white])
        text.textColor = .white
        text.keyboardType = UIKeyboardType.emailAddress
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let firstDividerLine: UIView = {
        let line = UIView()
        line.backgroundColor = .white
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let secondDividerLine: UIView = {
        let line = UIView()
        line.backgroundColor = .white
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
        addSubview(backgroundImage)
        addSubview(bottomView)
        addSubview(imageView)
        
        backgroundImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundImage.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        _ = imageView.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 120)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        bottomViewHeightConstraint = bottomView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)[3]//self.frame.height/2)
        
        resetSignUpConstraints(loginConstant: 0, signUpConstant: 20)
        
    }
    
    func createInputContainer(button: UIButton) {
        bottomView.addSubview(centerView)
        bottomView.addSubview(button)
        
        _ = centerView.anchor(bottomView.topAnchor, left: bottomView.leftAnchor, bottom: nil, right: bottomView.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 150)
        
        _ = button.anchor(centerView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 40)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.borderColor = UIColor.white.cgColor
        button.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
    }
    
    func resetSignUpConstraints(loginConstant: CGFloat, signUpConstant: CGFloat) {
        loginButton.removeFromSuperview()
        registerButton.removeFromSuperview()
        bottomView.addSubview(loginButton)
        bottomView.addSubview(registerButton)
        
        registerButton.layer.cornerRadius = 0
        registerButton.clipsToBounds = true
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        registerButton.layer.borderWidth = 0
        registerButton.layer.borderColor = UIColor.clear.cgColor
        loginButton.layer.cornerRadius = 0
        loginButton.clipsToBounds = true
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        loginButton.layer.borderWidth = 0
        loginButton.layer.borderColor = UIColor.clear.cgColor
        
        _ = loginButton.anchor(nil, left: nil, bottom: bottomView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: loginConstant, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        loginButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        
        _ = registerButton.anchor(nil, left: nil, bottom: bottomView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: signUpConstant, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        registerButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
    }
    
    func textFieldsAddedToCenterView() {
        centerView.addSubview(nameTextField)
        centerView.addSubview(firstDividerLine)
        centerView.addSubview(emailTextField)
        centerView.addSubview(secondDividerLine)
        centerView.addSubview(passwordTextField)
        
        nameTextField.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: centerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: centerView.widthAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: centerView.heightAnchor, multiplier: 1/3).isActive = true
        
        firstDividerLine.leftAnchor.constraint(equalTo: centerView.leftAnchor).isActive = true
        firstDividerLine.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        firstDividerLine.widthAnchor.constraint(equalTo: centerView.widthAnchor).isActive = true
        firstDividerLine.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
        
        emailTextField.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: firstDividerLine.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: centerView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: centerView.heightAnchor, multiplier: 1/3).isActive = true
        
        secondDividerLine.leftAnchor.constraint(equalTo: centerView.leftAnchor).isActive = true
        secondDividerLine.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        secondDividerLine.widthAnchor.constraint(equalTo: centerView.widthAnchor).isActive = true
        secondDividerLine.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
        
        passwordTextField.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: secondDividerLine.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: centerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: centerView.heightAnchor, multiplier: 1/3).isActive = true


    }
    
    func textFieldsAddedToCenterViewLogin() {
        centerView.addSubview(emailTextField)
        centerView.addSubview(secondDividerLine)
        centerView.addSubview(passwordTextField)
        
        emailTextField.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: centerView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: centerView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: centerView.heightAnchor, multiplier: 1/2).isActive = true
        
        secondDividerLine.leftAnchor.constraint(equalTo: centerView.leftAnchor).isActive = true
        secondDividerLine.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        secondDividerLine.widthAnchor.constraint(equalTo: centerView.widthAnchor).isActive = true
        secondDividerLine.heightAnchor.constraint(equalToConstant: 1.5).isActive = true

        passwordTextField.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: secondDividerLine.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: centerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: centerView.heightAnchor, multiplier: 1/2).isActive = true
        
        
    }
    
    func loginFunctionButton() {
            if !isLoginViewOpen {
                removeFieldsFromSuperView()
                bottomViewHeightConstraint?.constant = self.frame.height / 2 - 20
                centerView.alpha = 1
                createInputContainer(button: loginButton)
                textFieldsAddedToCenterViewLogin()
                isLoginViewOpen = true
                isReadyForLogin = true
            } else {
                centerView.alpha = 0
                centerView.removeFromSuperview()
                loginButton.removeFromSuperview()
                bottomViewHeightConstraint?.constant = 60
                resetSignUpConstraints(loginConstant: 0, signUpConstant: 20)
                isLoginViewOpen = false
                isReadyForLogin = false
            }
            animationLayoutIfNeeded()
    }
    
    func signupFunctionButton() {
            if !isSignupViewOpen {
                removeFieldsFromSuperView()
                bottomViewHeightConstraint?.constant = self.frame.height / 2 - 20
                centerView.alpha = 1
                createInputContainer(button: registerButton)
                textFieldsAddedToCenterView()
                isSignupViewOpen = true
                isReadyForLogin = true
            } else {
                centerView.alpha = 0
                centerView.removeFromSuperview()
                registerButton.removeFromSuperview()
                bottomViewHeightConstraint?.constant = 60
                resetSignUpConstraints(loginConstant: 0, signUpConstant: 20)
                isSignupViewOpen = false
                isReadyForLogin = false
            }
            animationLayoutIfNeeded()
    }
    
    func removeFieldsFromSuperView() {
        registerButton.removeFromSuperview()
        loginButton.removeFromSuperview()
        nameTextField.removeFromSuperview()
        firstDividerLine.removeFromSuperview()
        emailTextField.removeFromSuperview()
        secondDividerLine.removeFromSuperview()
        passwordTextField.removeFromSuperview()

    }
    
    func userSignUp() {
        //delegate?.userSignup()
    }
    
    func testAn() {
        //bottomViewHeightConstraint?.constant = 50
        animationLayoutIfNeeded()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
