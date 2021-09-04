//
//  FirestoreModel.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/29.
//

import Foundation
import Alamofire
import RxSwift
import Firebase
import FirebaseFirestoreSwift

struct Food: Codable {
    let name: String
    let price: Int
}

protocol FirestoreModelProtocol {
    func resetLastDocument()
    func create(shop: Shop, shopDocumentID: String) -> Single<Shop>
    func getShops() -> Single<[Shop]>
}

final class FirestoreShopModel: FirestoreModelProtocol {

    private var lastDocument: QueryDocumentSnapshot?

    // MARK: - Function

    func resetLastDocument() {
        self.lastDocument = nil
    }

    func getShops() -> Single<[Shop]> {

        let shopCollectionRef = FirestoreCosntant.getShopCollectionRef()
        let shopQuery = FirestoreCosntant.getShopQuery(collectionRef: shopCollectionRef, lastDocument: self.lastDocument)

        return Single<[Shop]>.create { single in

            shopQuery.getDocuments { [weak self] (documentSnapshots, error) in

                if let error = error {
                    single(.failure(error))
                }

                if let documentSnapshots = documentSnapshots {
                    let shops = documentSnapshots.documents.compactMap { self?.generateShop(documentSnapshot: $0) }
                    self?.lastDocument = documentSnapshots.documents.last
                    single(.success(shops))
                }
            }
            return Disposables.create()
        }
    }

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

    // MARK: - Private Function

    private func generateShop(documentSnapshot: DocumentSnapshot) -> Shop? {
        if let data = documentSnapshot.data(), let shop = try? Firestore.Decoder().decode(Shop.self, from: data) {
            return shop
        } else {
            return nil
        }
    }
}
