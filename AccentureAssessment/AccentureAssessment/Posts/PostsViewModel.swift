//
//  PostsViewModel.swift
//  AccentureAssessment
//
//  Created by Gurleen kaur on 12/5/25.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class PostsViewModel {
    
    // MARK: - Outlets
    private let service = PostsService()
    private let realmManager = DBManager()
    private let disposeBag = DisposeBag()
    
    let posts = BehaviorRelay<[Post]>(value: [])
    let errorMessage = PublishRelay<String>()
    
    // MARK: - Functions
    func numberOfPosts() -> Int {
        return posts.value.count
    }
    
    func post(at index: Int) -> Post {
        return posts.value[index]
    }
    
    func updatePost(at index: Int, isFav: Bool) {
        var currentPosts = posts.value
        currentPosts[index].isFavourite = isFav
        posts.accept(currentPosts)
    }
    
    func savePostsToDB(posts: [Post]) {
        realmManager.updatePostsPreservingFavorites(with: posts)
    }
    
    func fetchRealmPosts() {
        let localPosts = realmManager.fetchPosts()
        posts.accept(localPosts)
    }
    
    func fetchLaunchPosts() {
        let offlinePosts = realmManager.fetchPosts()
        posts.accept(offlinePosts)
        self.service.fetchPosts { [weak self] result in
            switch result {
            case .success(let onlinePosts):
                if offlinePosts != onlinePosts {
                    self?.savePostsToDB(posts: onlinePosts)
                    let newPosts = self?.realmManager.fetchPosts() ?? []
                    self?.posts.accept(newPosts)
                }
            case .failure(let error):
                self?.errorMessage.accept(error.localizedDescription)
            }
        }
    }
}

