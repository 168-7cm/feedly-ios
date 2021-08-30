//
//  FeedlyViewModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/27.
//

import Foundation
import RxSwift
import RxCocoa

protocol FeedlyViewModelInputs {
    func getFeeds()
    func resetContinuation()
}

protocol FeedlyViewModelOutputs {
    var loading: Observable<Bool> { get }
    var error: Observable<Bool> { get }
    var errorText: Observable<String> { get }
    var feedItems: Observable<[FeedItem]> { get }
}

protocol FeedlyViewModelType {
    var inputs: FeedlyViewModelInputs { get }
    var outputs: FeedlyViewModelOutputs { get }
}

final class FeedlyViewModel: FeedlyViewModelInputs, FeedlyViewModelOutputs, FeedlyViewModelType {

    // FeedlyViewModelType
    var inputs: FeedlyViewModelInputs { return self }
    var outputs: FeedlyViewModelOutputs { return self }

    // FeedlyViewModelOutputs
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    var loading: Observable<Bool> { return self.loadingRelay.asObservable() }

    private let errorRelay = BehaviorRelay<Bool>(value: false)
    var error: Observable<Bool> { return self.errorRelay.asObservable() }

    private let errorTextRelay = BehaviorRelay<String>(value: "")
    var errorText: Observable<String> { return self.errorTextRelay.asObservable() }

<<<<<<< Updated upstream
    private let feedItemsRelay = BehaviorRelay<[FeedItem]>(value: [])
    var feedItems: Observable<[FeedItem]> { return self.feedItemsRelay.asObservable() }
=======
    private let feedItemsRelay = BehaviorRelay<[AnyObject]>(value: [])
    var feedItems: Observable<[AnyObject]> { return self.feedItemsRelay.asObservable() }
>>>>>>> Stashed changes

    // パラメーター
    private let feedlyStreamApi: FeedlyStreamModelProtocol
    private let feedlyAuthApi: FeedlyAuthModelProtocol
    private weak var view: FeedlyViewController?
    private let disposeBag = DisposeBag()
    private var continuation: String?

    // イニシャライザ
    init(view: FeedlyViewController, authApi: FeedlyAuthModelProtocol, StreamApi: FeedlyStreamModelProtocol) {
        self.view = view
        self.feedlyAuthApi = authApi
        self.feedlyStreamApi = StreamApi

        self.view?.nativeAD.subscribe( onNext: { [weak self] nativeAD in
            print(nativeAD)
        }).disposed(by: disposeBag)
    }

    // FeedlyViewModelInputs
    func resetContinuation() {
        self.continuation = nil
    }

    func getFeeds() {

        // ローティングの開始
        loadingRelay.accept(true)

        // フィードを取得する
        feedlyAuthApi.apiRequest()
            .flatMap { self.feedlyStreamApi.apiRequest(access_token: $0, continuation: self.continuation) }
            .subscribe(

                // API通信成功
                onSuccess: { [weak self] feed in
                    self?.hundleApiResult(feed: feed, error: nil)
                },

                // API通信失敗
                onFailure: { [weak self] error  in
                    self?.hundleApiResult(feed: nil, error: error as? CustomError)
                }
            ).disposed(by: self.disposeBag)
    }

    private func hundleApiResult(feed: Feed?, error: CustomError?) {

        // ローディングの終了
        loadingRelay.accept(false)

<<<<<<< Updated upstream
        if let feed = feed {
            feedItemsRelay.accept(self.continuation != nil ? feedItemsRelay.value + feed.items : feed.items)
=======
        if let feed = feed, let feedItems = feed.items as? [AnyObject] {

            // ここでランダムに広告を挟む
            let feedAndAD: [AnyObject] = feedItems// + NativeADs
            feedItemsRelay.accept(self.continuation != nil ? feedItemsRelay.value + feedAndAD : feedAndAD)
>>>>>>> Stashed changes
            self.continuation = feed.continuation
        }

        if let error = error {
            errorRelay.accept(true)
            errorTextRelay.accept(error.rawValue)
        }
    }
}
