//
//  CreateShopViewModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/02.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

protocol CreateShopViewModelInputs {
    func createShop()
    func configureWith()
}

protocol CreateShopViewModelOutputs {
    var loading: Observable<Bool> { get }
    var shop: Observable<Shop> { get }
    var error: Observable<Error> { get }

}

protocol CreateShopViewModelType {
    var inputs: CreateShopViewModelInputs { get }
    var outputs: CreateShopViewModelOutputs { get }
}

final class CreateShopViewModel: CreateShopViewModelInputs, CreateShopViewModelOutputs , CreateShopViewModelType {
    // MARK: - Properties

    private let createShopModel = CreateShopModel()
    private let disposeBag = DisposeBag()

    // viewはここを経由してViewModelを扱う
    var inputs: CreateShopViewModelInputs { return self }
    var outputs: CreateShopViewModelOutputs { return self }

    private let loadingRelay = PublishRelay<Bool>()
    var loading: Observable<Bool> { return self.loadingRelay.asObservable() }

    private let shopRelay = PublishRelay<Shop>()
    var shop: Observable<Shop> { return self.shopRelay.asObservable() }

    private let erroRelay = PublishRelay<Error>()
    var error: Observable<Error> { return self.erroRelay.asObservable() }


    // MARK: - Function

    // 遷移元のVCでViewModelのこのメソッドを呼び出す
    func configureWith() {
        // 渡したい値がある時はここで入れる
    }

    func createShop() {

        // ローディングの開始
        loadingRelay.accept(true)

        // 今回はここで作成しているが、本当はViewからの値で作成する予定
        let shop = Shop(name: "すき家", location: "東京都新宿区高田馬場", createdAt: Date().toString(), foods: [Food(name: "牛丼", price: 500)])
        let shopDocumentID = FirestoreCosntant.getShopDocumentID()
        self.createShopModel.create(shop: shop, shopDocumentID: shopDocumentID).subscribe(

            // 作成に成功した場合
            onSuccess: { [weak self] shop in
                self?.handleApiResult(shop: shop, error: nil)
            },

            // 作成に失敗した場合
            onFailure: { [weak self] error in
                self?.handleApiResult(shop: nil, error: error)
            }
        ).disposed(by: disposeBag)
    }

    // MARK: - Private Function

    private func handleApiResult(shop: Shop?, error: Error?) {

        // ローティングの中止
        loadingRelay.accept(false)

        if let shop = shop {
            shopRelay.accept(shop)
        }

        if let error = error {
            erroRelay.accept(error)
        }
    }
}
