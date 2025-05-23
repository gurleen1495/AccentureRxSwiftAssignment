//
//  FavouritesViewModel.swift
//  AccentureAssessment
//
//  Created by Gurleen kaur on 13/5/25.

import RxSwift
import RxCocoa
import RealmSwift

class FavouritesViewModel {

    // MARK: - Variables
    let favPosts = BehaviorRelay<[Post]>(value: [])
    let errorMessage = PublishRelay<String>()
    let manager = DBManager()

    // MARK: - Functions
    func fetchFavouritePosts() {
        let realmPosts: Results<PostObject> = manager.fetchPostsForFavourites()
        let posts: [Post] = realmPosts.map { Post(from: $0) }
        favPosts.accept(posts)
    }

    func post(at index: Int) -> Post {
        return favPosts.value[index]
    }

    func numberOfPosts() -> Int {
        return favPosts.value.count
    }

    func removeFavourite(at index: Int) {
        let post = favPosts.value[index]
        manager.updatePostForFavourite(id: post.id, isFav: false)
        fetchFavouritePosts()
    }
}
