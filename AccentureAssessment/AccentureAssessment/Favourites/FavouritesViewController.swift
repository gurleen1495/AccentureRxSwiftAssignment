//
//  FavouritesViewController.swift
//  AccentureAssessment
//
//  Created by Gurleen kaur on 12/5/25.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class FavouritesViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel = FavouritesViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Outlets
    @IBOutlet weak var favouritesTableView: UITableView!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFavouritePosts()
    }
    
    // MARK: - Functions
    private func bindViewModel() {
        viewModel.favPosts
            .asDriver()
            .drive(onNext: { [weak self] posts in
                self?.favouritesTableView.reloadData()
                self?.noFavoritesLabel.isHidden = !posts.isEmpty
            })
            .disposed(by: disposeBag)
    }
    
    func navigateToLoginScreen() {
        UserDefaults.standard.removeObject(forKey: Constants.Strings.kIsLoggedIn)
        let storyboard = UIStoryboard(name: Constants.Storyboard.kMainStoryboard, bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: Constants.Identifier.kLoginViewController)
        
        if #available(iOS 13.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = scene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginVC
                sceneDelegate.window?.makeKeyAndVisible()
                return
            }
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = loginVC
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - Actions
    @IBAction func logoutButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: Constants.Alerts.kLogout, message: Constants.Alerts.kLogoutMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.Alerts.kCancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Constants.Alerts.kLogout, style: .destructive) { [weak self] _ in
            self?.navigateToLoginScreen()
        })
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegate & DataSource
extension FavouritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfPosts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.kFavouritesCell, for: indexPath) as! FavouritesTableViewCell
        let post = viewModel.post(at: indexPath.row)
        cell.configure(post: post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeFavourite(at: indexPath.row)
        }
    }
}
