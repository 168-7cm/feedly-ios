//
//  FirestoreConstant.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/31.
//

import Foundation
import Firebase

enum firestoreError: String, Error {
    case failedToCreate = "ルームの作成に失敗しました"
    case failedToDecpde = "予期せぬエラーが発生しました"
}

struct FirestoreCosntant {

    static let shop = "shop"
    static let food = "food"
    static let field = "createdAt"
    static let limit = 20
    static let likedUserIDs = "likedUserIDs"
    static let blockedUserIDs = "blockedUserIDs"

    // ショップのリファレンス
    static func getShopCollectionRef() -> CollectionReference {
        return Firestore.firestore().collection(FirestoreCosntant.shop)
    }

    // ショップ用クエリ
    static func getShopQuery(collectionRef: CollectionReference, lastDocument: DocumentSnapshot?) -> Query {
        if let lastDocument = lastDocument {
            return collectionRef.limit(to: FirestoreCosntant.limit).order(by: FirestoreCosntant.field, descending: true).start(atDocument: lastDocument)

        } else {
            return collectionRef.limit(to: FirestoreCosntant.limit).order(by: FirestoreCosntant.field, descending: true)
        }
    }

    // ショップのドキュメントID
    static func getShopDocumentID() -> String {
        return self.getShopCollectionRef().document().documentID
    }

    // フードのリファレンス
    static func getFoodCollectionRef(shopDocumentID: String) -> CollectionReference {
        return getShopCollectionRef().document(shopDocumentID).collection(FirestoreCosntant.food)
    }

    // フード用クエリ
    static func getFeedQuery(collectionRef: CollectionReference) -> Query {
        return collectionRef.limit(to: FirestoreCosntant.limit).order(by: FirestoreCosntant.field, descending: false)
    }

    // フードのドキュメントID
    static func getFeedDocumentID(shopDocumentID: String) -> String {
        return self.getFoodCollectionRef(shopDocumentID: shopDocumentID).document().documentID
    }
}
