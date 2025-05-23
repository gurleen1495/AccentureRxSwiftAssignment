//
//  PostsViewController.swift
//  AccentureAssessment
//
//  Created by Gurleen kaur on 12/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class PostsViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel = PostsViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - Outlets
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var noPostsLabel: UILabel!
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        postsTableView.rowHeight = UITableView.automaticDimension
        postsTableView.estimatedRowHeight = 150
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetchLaunchPosts()
        postsTableView.reloadData()
    }
    
    // MARK: - Functions
    func setupBindings() {
        viewModel.posts
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                self?.postsTableView.reloadData()
                self?.noPostsLabel.isHidden = !posts.isEmpty
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showError(message)
            })
            .disposed(by: disposeBag)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: Constants.Alerts.kError, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.Alerts.kOK, style: .default))
        present(alert, animated: true)
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
        alert.addAction(UIAlertAction(title: Constants.Alerts.kLogout, style: .destructive) { _ in
            self.navigateToLoginScreen()
        })
        present(alert, animated: true)
    }
}

// MARK: - TableViewDataSource, TableViewDelegate
extension PostsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfPosts()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.kPostCell, for: indexPath) as! PostsTableViewCell
        let cellData = viewModel.post(at: indexPath.row)
        cell.setData(post: cellData)
        if let isCellFav =  cellData.isFavourite {
            cell.selectionStyle = isCellFav ? .none : .default
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = viewModel.post(at: indexPath.row)
        if let isFav = cellData.isFavourite, isFav == true {
         return
        }
        self.toggleFavorite(post: cellData, at: indexPath)
    }

    private func toggleFavorite(post: Post, at indexPath: IndexPath) {
        let alert = UIAlertController(title: Constants.Alerts.kAddPostToFavTitle, message: Constants.Alerts.kAddPostToFavMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.Alerts.kOK, style: .default) {
            (action) -> Void in
            let manager = DBManager()
            manager.updatePostForFavourite(id: post.id, isFav: true)
            self.viewModel.updatePost(at: indexPath.row, isFav: true)
            self.postsTableView.reloadData()
            if let cell = self.postsTableView.cellForRow(at: indexPath) as? PostsTableViewCell {
                cell.setData(post: self.viewModel.post(at: indexPath.row))
            }
        }
        let cancelAction = UIAlertAction(title: Constants.Alerts.kCancel, style: .cancel) {
            (action) -> Void in
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: false, completion: nil)
    }
}

