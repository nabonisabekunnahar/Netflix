//
//  AccountViewController.swift
//  Netflix
//
//  Created by Sayaka Alam on 10/1/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountViewController: UIViewController {
    
    private let db = Firestore.firestore()
    private var username: String = "User"
    private var email: String = "Email"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfile")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let optionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: OptionCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let options = [
        Option(title: "View Info", icon: "info.circle"),
        Option(title: "Edit Username", icon: "pencil"),
        Option(title: "Edit Password", icon: "lock.circle"),
        Option(title: "Logout", icon: "power")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(emailLabel)
        view.addSubview(optionsCollectionView)
        
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        
        setupConstraints()
        fetchUserInfo()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            optionsCollectionView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            optionsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            optionsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func fetchUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self, error == nil, let document = document, document.exists else {
                print("Failed to fetch user info: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            if let data = document.data() {
                self.username = data["username"] as? String ?? "User"
                self.email = data["email"] as? String ?? "Email"
                
                DispatchQueue.main.async {
                    self.usernameLabel.text = self.username
                    self.emailLabel.text = self.email
                }
            }
        }
    }
}

extension AccountViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionCell.identifier, for: indexPath) as? OptionCell else {
            return UICollectionViewCell()
        }
        
        let option = options[indexPath.row]
        cell.configure(with: option)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showUserInfo()
        case 1:
            editUsername()
        case 2:
            editPassword()
        case 3:
            logoutUser()
        default:
            break
        }
    }
    
    private func showUserInfo() {
        // Create the alert
        let alert = UIAlertController(
            title: "👤 User Information",
            message: """
            📧 Email: \(email)
            🆔 Username: \(username)
            """,
            preferredStyle: .alert
        )
        
        // Add "Close" action
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        closeAction.setValue(UIColor.red, forKey: "titleTextColor") // Red color for the action button
        alert.addAction(closeAction)
        
        // Customize the attributed title and message
        let titleFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold)]
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)]
        
        let attributedTitle = NSAttributedString(string: "👤 User Information", attributes: titleFont)
        let attributedMessage = NSAttributedString(
            string: """
            📧 Email: \(email)
            🆔 Username: \(username)
            """,
            attributes: messageFont
        )
        
        // Apply custom fonts to the title and message
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        // Adjust the alert view size by modifying its title and message
        // Note: Avoid adding subviews to `UIAlertController` as it disrupts its functionality.

        // Present the alert
        present(alert, animated: true)
    }

    
    private func editUsername() {
        let alert = UIAlertController(title: "Edit Username", message: "Enter a new username.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "New username"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self, let newUsername = alert.textFields?.first?.text, !newUsername.isEmpty else { return }
            self.updateUsername(to: newUsername)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func editPassword() {
        let alert = UIAlertController(title: "Edit Password", message: "Enter a new password.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "New password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let newPassword = alert.textFields?.first?.text, !newPassword.isEmpty else { return }
            self.updatePassword(to: newPassword)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func updateUsername(to newUsername: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).updateData(["username": newUsername]) { [weak self] error in
            if let error = error {
                print("Failed to update username: \(error.localizedDescription)")
            } else {
                print("Username updated to \(newUsername)")
                self?.username = newUsername
                DispatchQueue.main.async {
                    self?.usernameLabel.text = self?.username
                }
            }
        }
    }
    
    private func updatePassword(to newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Failed to update password: \(error.localizedDescription)")
            } else {
                print("Password updated successfully")
            }
        }
    }
    
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            print("User logged out")
            
            let signInVC = SignInViewController() // Replace with your Sign-In view controller
            let navController = UINavigationController(rootViewController: signInVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true) {
                self.navigationController?.setViewControllers([], animated: false)
            }
        } catch {
            print("Failed to log out: \(error.localizedDescription)")
        }
    }
}

struct Option {
    let title: String
    let icon: String
}

class OptionCell: UICollectionViewCell {
    static let identifier = "OptionCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .red // Red tint for icons
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        contentView.backgroundColor = UIColor.darkGray
        contentView.layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with option: Option) {
        titleLabel.text = option.title
        iconImageView.image = UIImage(systemName: option.icon)
    }
}
