//
//  FireBaseViewModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/29.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import GoogleMobileAds

protocol ShopViewModelInputs {
    func didSelectedShop(indexPath: IndexPath)
    func createShopButtonDidTapped()
    func getShops(nativeAdsObserbavle: Observable<[GADNativeAd]>?)
    func configureWith()
}

protocol ShopViewModelOutputs {
    var shops: Observable<[AnyObject]> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<Error> { get }
    var gotoEditShop: Observable<Shop> { get }
    var gotoCreateShop: Observable<Bool> { get }
}

protocol ShopViewModelType {
    var inputs: ShopViewModelInputs { get }
    var outputs: ShopViewModelOutputs { get }
}

final class ShopViewModel: ShopViewModelInputs, ShopViewModelOutputs, ShopViewModelType {

    // MARK: - Properties

    private let shopModel: ShopModelProtocol = ShopModel()
    private let disposeBag = DisposeBag()

    // viewはここを経由してViewModelを扱う
    var inputs: ShopViewModelInputs { return self }
    var outputs: ShopViewModelOutputs { return self }

    // Viewが購読する
    private let shopsRelay = BehaviorRelay<[AnyObject]>(value: [])
    var shops: Observable<[AnyObject]> { return self.shopsRelay.asObservable() }

    private let errorRelay = PublishRelay<Error>()
    var error: Observable<Error> { return self.errorRelay.asObservable() }

    private let loadingRelay = PublishRelay<Bool>()
    var loading: Observable<Bool> { return self.loadingRelay.asObservable() }

    private let gotoEditShopRelay = PublishRelay<Shop>()
    var gotoEditShop: Observable<Shop> { return self.gotoEditShopRelay.asObservable() }

    private let goToCreateShopRelay = PublishRelay<Bool>()
    var gotoCreateShop: Observable<Bool> { return self.goToCreateShopRelay.asObservable() }

    // MARK: - Function

    func createShopButtonDidTapped() {
        goToCreateShopRelay.accept(true)
    }

    // 編集画面遷移させる
    func didSelectedShop(indexPath: IndexPath) {
        guard let shop = shopsRelay.value[indexPath.row] as? Shop else { return }
        gotoEditShopRelay.accept(shop)
    }

    //ここで値を渡す場合は渡す　今回は渡さない
    func configureWith() {

    }

    func getShops(nativeAdsObserbavle: Observable<[GADNativeAd]>?) {

        // ローディングの開始
        loadingRelay.accept(true)

        guard let nativeAdsObservable = nativeAdsObserbavle else { return }

        // API取得結果と広告を合成する
        Observable.zip(
            self.shopModel.getShops().asObservable(),
            nativeAdsObservable
        ).subscribe(

            // 成功した場合の処理
            onNext: { [weak self] shops, nativeAds in
                self?.handleApiResult(shops: shops, nativeAds: nativeAds, error: nil)
            },

            // 失敗した場合の処理
            onError: { [weak self] error in
                self?.handleApiResult(shops: nil, nativeAds: nil, error: error)
            }

        ).disposed(by: disposeBag)
    }

    // MARK: - Private Function

    private func handleApiResult(shops: [Shop]?, nativeAds: [GADNativeAd]?, error: Error?) {

        // ローディングの終了
        loadingRelay.accept(false)

        // 成功した場合
        if let shops = shops, let nativeAds = nativeAds {
            let shops = insertNativeAds(shops: shops, nativeAds: nativeAds)
            shopsRelay.accept(shopsRelay.value + shops)
        }

        // 失敗した場合
        if let error = error {
            errorRelay.accept(error)
        }
    }

    // 6個おきに広告を挟む
    private func insertNativeAds(shops: [Shop], nativeAds: [GADNativeAd]) -> [AnyObject] {
        var shops = shops as [AnyObject]
        shops.enumerated().forEach { (index, nativeAd) in
            let index = (index+1)*6
            if index < shops.count {
                shops.insert(nativeAd, at: index)
            }
        }
        return shops
    }
}
