//
//  CreateShopModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/02.
//

import Foundation
import Alamofire
import RxSwift
import Firebase
import FirebaseFirestoreSwift

protocol CreateShopModelProtocol {
    func create(shop: Shop, shopDocumentID: String) -> Single<Shop>
}

final class CreateShopModel: CreateShopModelProtocol {

    // MARK: - Function

    //　ショップを作成する
    func create(shop: Shop, shopDocumentID: String) -> Single<Shop> {

        return Single<Shop>.create { single in
            if let data = try? Firestore.Encoder().encode(shop) {

                // Firestoreにデータを保存する
                FirestoreCosntant.getShopCollectionRef().document(shopDocumentID).setData(data) { error in

                    // データ保存に失敗
                    if let _ = error {
                        single(.failure(firestoreError.failedToCreate))

                    // データ保存に成功
                    } else {
                        single(.success(shop))
                    }
                }
                // デコードに失敗
            } else {
                single(.failure(firestoreError.failedToDecpde))
            }
            return Disposables.create()
        }
    }
}
