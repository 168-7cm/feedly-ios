//
//  FeedlyViewModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/27.
//

import Foundation
import RxSwift
import RxCocoa

protocol FeedlyViewModelProtocol {
    var loading: Observable<Bool> { get }
    var error: Observable<Bool> { get }
    var errorText: Observable<String> { get }
    var feedItems: Observable<[FeedItem]> { get }

    func getFeeds()
    func resetContinuation()
}

final class FeedlyViewModel: FeedlyViewModelProtocol {

    // パラメーター
    private let feedlyStreamApi: FeedlyStreamApiProtocol
    private let feedlyAuthApi: FeedlyAuthApiProtocol
    private let disposeBag = DisposeBag()
    private var continuation: String?

    // Modelの結果を流すSujbectとViewControllerが参照するObservable
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    var loading: Observable<Bool> { return self.loadingRelay.asObservable() }

    private let errorRelay = BehaviorRelay<Bool>(value: false)
    var error: Observable<Bool> { return self.errorRelay.asObservable() }

    private let errorTextRelay = BehaviorRelay<String>(value: "")
    var errorText: Observable<String> { return self.errorTextRelay.asObservable() }

    private let feedItemsRelay = BehaviorRelay<[FeedItem]>(value: [])
    var feedItems: Observable<[FeedItem]> { return self.feedItemsRelay.asObservable() }

    // イニシャライザ
    init(authApi: FeedlyAuthApiProtocol, StreamApi: FeedlyStreamApiProtocol) {
        self.feedlyAuthApi = authApi
        self.feedlyStreamApi = StreamApi
    }

    func resetContinuation() {
        self.continuation = nil
    }

    func getFeeds() {
        // リクエスト開始時の処理
        executeStartRequestAction()

        // フィードを取得する
        feedlyAuthApi.apiRequest()
            .flatMap { self.feedlyStreamApi.apiRequest(access_token: $0, continuation: self.continuation) }
            .subscribe(

                // API通信成功
                onSuccess: { [weak self] feed in
                    self?.executeSuccessResponseAction(feed: feed)
                },

                // API通信失敗
                onFailure: { [weak self] error in
                    if let error = error as? CustomError {
                        self?.executeErrorResponseAction(error: error)
                    }
                }
            ).disposed(by: self.disposeBag)
    }

    private func executeStartRequestAction() {
        loadingRelay.accept(true)
        errorRelay.accept(false)
    }

    private func executeErrorResponseAction(error: CustomError) {
        loadingRelay.accept(false)
        errorRelay.accept(true)
        errorTextRelay.accept(error.rawValue)
    }

    private func executeSuccessResponseAction(feed: Feed) {
        self.continuation = feed.continuation
        feedItemsRelay.accept(self.continuation != nil ? feedItemsRelay.value + feed.items : feed.items)
        loadingRelay.accept(false)
    }
}
