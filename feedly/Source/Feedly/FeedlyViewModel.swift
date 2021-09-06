//
//  FeedlyViewModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/27.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleMobileAds

protocol FeedlyViewModelInputs {
    func getFeeds(nativeAdsStream: Observable<[GADNativeAd]>)
    func resetContinuation()
    func congigureWith()
}

protocol FeedlyViewModelOutputs {
    var loading: Observable<Bool> { get }
    var error: Observable<Bool> { get }
    var errorText: Observable<String> { get }
    var feedItems: Observable<[AnyObject]> { get }
}

protocol FeedlyViewModelType {
    var inputs: FeedlyViewModelInputs { get }
    var outputs: FeedlyViewModelOutputs { get }
}

final class FeedlyViewModel: FeedlyViewModelInputs, FeedlyViewModelOutputs, FeedlyViewModelType {

    // MARK: - Properties

    private let feedlyStreamApi = FeedlyStreamModel()
    private let feedlyAuthApi = FeedlyAuthModel()
    private let disposeBag = DisposeBag()
    private var continuation: String?
    private var nativeAdObservable: Observable<[GADNativeAd]>?

    // viewはここを経由してViewModelを扱う
    var inputs: FeedlyViewModelInputs { return self }
    var outputs: FeedlyViewModelOutputs { return self }

    // Viewが購読する
    private let loadingRelay = PublishRelay<Bool>()
    var loading: Observable<Bool> { return self.loadingRelay.asObservable() }

    private let errorRelay = PublishRelay<Bool>()
    var error: Observable<Bool> { return self.errorRelay.asObservable() }

    private let errorTextRelay = PublishRelay<String>()
    var errorText: Observable<String> { return self.errorTextRelay.asObservable() }

    private let feedItemsRelay = BehaviorRelay<[AnyObject]>(value: [])
    var feedItems: Observable<[AnyObject]> { return self.feedItemsRelay.asObservable() }

    // MARK: - Function

    func congigureWith() {
        
    }

    func resetContinuation() {
        self.continuation = nil
    }

    func getFeeds(nativeAdsStream: Observable<[GADNativeAd]>) {

        // ローティングの開始
        loadingRelay.accept(true)

        let feedStream: Observable<Feed> = feedlyAuthApi.apiRequest().flatMap { self.feedlyStreamApi.apiRequest(access_token: $0, continuation: self.continuation) }.asObservable()

        Observable.zip(
            feedStream,
            nativeAdsStream
        ).subscribe(
            onNext: { [weak self] feed, nativeAds in
                self?.hundleApiResult(feed: feed, nativeAds: nativeAds)
            },
            onError: { [weak self] error in
                self?.handleErrorResult(error: error)
            }
        ).disposed(by: disposeBag)
    }

    // MARK: - Private Function
    
    private func hundleApiResult(feed: Feed, nativeAds: [GADNativeAd]) {
        // ローディングの終了
        loadingRelay.accept(false)

        let feedItems = insertNativeAds(feeditems: feed.items, nativeAds: nativeAds)
        feedItemsRelay.accept(self.continuation != nil ? feedItemsRelay.value + feedItems: feedItems)
        self.continuation = feed.continuation
    }

    private func handleErrorResult(error: Error) {
        loadingRelay.accept(false)
        errorRelay.accept(false)
        errorTextRelay.accept("失敗")
    }

    // 6個おきに広告を挟む
    private func insertNativeAds(feeditems: [FeedItem], nativeAds: [GADNativeAd]) -> [AnyObject] {
        var feeditems = feeditems as [AnyObject]
        nativeAds.enumerated().forEach { (index, nativeAd) in
            let index = (index+1)*6
            if index < feeditems.count {
                feeditems.insert(nativeAd, at: index)
            }
        }
        return feeditems
    }
}
