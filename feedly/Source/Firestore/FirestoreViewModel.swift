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

protocol FirestoreViewModelInputs {
    func createShop()
    func getShops()
    func configureWith(shopDocumentID: String)
}

protocol FirestoreViewModelOutputs {
    var shops: Observable<[AnyObject]> { get }
    var error: Observable<Error> { get }
    var gotoDetail: Observable<String> { get }
}

protocol FirestoreViewModelType {
    var inputs: FirestoreViewModelInputs { get }
    var outputs: FirestoreViewModelOutputs { get }
}

final class FirestoreViewModel: FirestoreViewModelInputs, FirestoreViewModelOutputs, FirestoreViewModelType {

    // MARK: - Properties

    private let firestoreModel: FirestoreModelProtocol
    private var nativeAdObservable: Observable<[GADNativeAd]>
    private let disposeBag = DisposeBag()

    // viewはここを経由してViewModelを扱う
    var inputs: FirestoreViewModelInputs { return self }
    var outputs: FirestoreViewModelOutputs { return self }

    // Viewが購読する
    private let shopsRelay = BehaviorRelay<[AnyObject]>(value: [])
    var shops: Observable<[AnyObject]> { return self.shopsRelay.asObservable() }

    private let errorRelay = PublishRelay<Error>()
    var error: Observable<Error> { return self.errorRelay.asObservable() }

    private let gotoDetailSignal: Driver<String> = Driver.never()
    var gotoDetail: Observable<String> { return gotoDetailSignal.asObservable() }

    // MARK: - initilazier

    init(nativeAdObservable: Observable<[GADNativeAd]>, firestoreModel: FirestoreModelProtocol) {
        self.nativeAdObservable = nativeAdObservable
        self.firestoreModel = firestoreModel
    }

    // MARK: - Function

    // 何かを返すべき
    func configureWith(shopDocumentID: String) {
        self.gotoDetailSignal
    }

    func createShop() {
        let shop = Shop(name: "すき家", location: "東京都新宿区高田馬場", createdAt: Date().toString(), foods: [Food(name: "牛丼", price: 500)])
        let shopDocumentID = FirestoreCosntant.getShopDocumentID()
        self.firestoreModel.create(shop: shop, shopDocumentID: shopDocumentID).subscribe(

            // ショップの作成に成功した時
            onSuccess: { [weak self] shop in
                print(self)
            },

            // ショップの作成に失敗した時
            onFailure: { [weak self] error in
                print(self)
            }
        ).disposed(by: disposeBag)
    }

    func getShops() {

        // Firestoreと広告を合成する
        Observable.zip(
            self.firestoreModel.getShops().asObservable(),
            self.nativeAdObservable
        ).subscribe(

            // 成功した場合の処理
            onNext: { [weak self] shops, nativeAds in
                self?.handleApiResult(shops: shops, nativeAds: nativeAds)
            },

            // 失敗した場合の処理
            onError: { [weak self] error in
                self?.handleErrorResult(error: error)
            }

        ).disposed(by: disposeBag)
    }

    // MARK: - Private Function

    private func handleApiResult(shops: [Shop], nativeAds: [GADNativeAd]) {
        let shops = insertNativeAds(shops: shops, nativeAds: nativeAds)
        shopsRelay.accept(shops)
    }

    private func handleErrorResult(error: Error) {
        errorRelay.accept(error)
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

    private func didGetShops(shops: [Shop]?, error: Error?) {

        if let shops = shops {
            shopsRelay.accept(shops as [AnyObject])
        }

        if let error = error {
            errorRelay.accept(error)
        }
    }
}
