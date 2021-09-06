//
//  EditShopView.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/06.
//

import Foundation
import Alamofire
import RxSwift
import Firebase
import FirebaseFirestoreSwift

protocol EditShopModelProtocol {
    func edit(shop: Shop) -> Single<Shop>
}

final class EditShopModel: EditShopModelProtocol {

    // MARK: - Function

    func edit(shop: Shop) -> Single<Shop> {

        return Single<Shop>.create { single in

            if let data = try? Firestore.Encoder().encode(shop) {

                // Firestoreのデータを上書きする
                FirestoreCosntant.getShopCollectionRef().document(shop.documentID).setData(data) { error in

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
