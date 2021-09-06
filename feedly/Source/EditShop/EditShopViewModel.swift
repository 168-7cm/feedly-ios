//
//  EditShopViewModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/06.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

protocol EditShopViewModelInputs {
    func editShop(shop: Shop)
    func configureWith(shop: Shop)
}

protocol EditShopViewModelOutputs {
    var loading: Observable<Bool> { get }
   // var shop: Observable<Shop> { get }
    var error: Observable<Error> { get }

}

protocol EditShopViewModelType {
    var inputs: EditShopViewModelInputs { get }
    var outputs: EditShopViewModelOutputs { get }
}

final class EditShopViewModel: EditShopViewModelInputs, EditShopViewModelOutputs, EditShopViewModelType {

    // MARK: - Properties

    private let editShopModel: EditShopModelProtocol = EditShopModel()
    private let disposeBag = DisposeBag()
    private var shop: Shop?

    // viewはここを経由してViewModelを扱う
    var inputs: EditShopViewModelInputs { return self }
    var outputs: EditShopViewModelOutputs { return self }

    private let loadingRelay = PublishRelay<Bool>()
    var loading: Observable<Bool> { return self.loadingRelay.asObservable() }

    private let shopRelay = PublishRelay<Shop>()
   // var shops: Observable<Shop> { return self.shopRelay.asObservable() }

    private let erroRelay = PublishRelay<Error>()
    var error: Observable<Error> { return self.erroRelay.asObservable() }


    // MARK: - Function

    // 渡したい値がある時はここで入れる
    func configureWith(shop: Shop) {
        self.shop = shop
    }

    func editShop(shop: Shop) {

        // ローディングの開始
        loadingRelay.accept(true)

        // 今回はここで作成しているが、本当はViewからの値で編集する予定
        let shopDocumentID = shop.documentID
        let shop = Shop(name: "変更済み", location: shop.location, createdAt: shop.createdAt, documentID: shopDocumentID, foods: shop.foods)
        self.editShopModel.edit(shop: shop).subscribe(

            // 更新に成功した場合
            onSuccess: { [weak self] shop in
                self?.handleApiResult(shop: shop, error: nil)
            },

            // 更新に失敗した場合
            onFailure: { [weak self] error in
                self?.handleApiResult(shop: nil, error: error)
            }
        ).disposed(by: disposeBag)
    }

    // MARK: - Private Function

    private func handleApiResult(shop: Shop?, error: Error?) {

        // ローティングの中止
        loadingRelay.accept(false)

        // 更新に成功した場合
        if let shop = shop {
            shopRelay.accept(shop)
        }

        // 更新に失敗した場合
        if let error = error {
            erroRelay.accept(error)
        }
    }
}
