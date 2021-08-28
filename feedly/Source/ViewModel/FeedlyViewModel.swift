//
//  FeedlyViewModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/27.
//

import Foundation
import RxSwift
import RxCocoa

final class FeedlyViewModel {

    private let feedlyStreamApi: FeedlyStreamApiProtocol
    private let feedlyAuthApi: FeedlyAuthApiProtocol
    private let disposeBag = DisposeBag()
    private var continuation: String?

    // ViewController側で利用するためのプロパティ
    let isLoading = BehaviorRelay<Bool>(value: false)
    let isError = BehaviorRelay<Bool>(value: false)
    let errorText = BehaviorRelay<String>(value: "")
    let feedItems = BehaviorRelay<[FeedItem]>(value: [])

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

        // グチャグチャ
        // フィードを取得する
        feedlyAuthApi.apiRequest().subscribe(

            // API通信成功
            onSuccess: { [weak self] access_token in
                self?.feedlyStreamApi.apiRequest(access_token: access_token, continuation: self?.continuation).subscribe(

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
                ).disposed(by: self!.disposeBag)
            },

            // API通信失敗
            onFailure: { [weak self] error in
                if let error = error as? CustomError {
                    self?.executeErrorResponseAction(error: error)
                }
            }
        ).disposed(by: disposeBag)
    }

    private func executeStartRequestAction() {
        isLoading.accept(true)
        isError.accept(false)
    }

    private func executeErrorResponseAction(error: CustomError) {
        isLoading.accept(false)
        isError.accept(true)
        errorText.accept(error.rawValue)
    }

    private func executeSuccessResponseAction(feed: Feed) {
        feedItems.accept(self.continuation != nil ? feedItems.value + feed.items : feed.items)
        self.continuation = feed.continuation
        isLoading.accept(false)
    }
}
