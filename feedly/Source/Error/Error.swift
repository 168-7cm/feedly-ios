//
//  Error.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/28.
//

import Foundation

enum CustomError: String, Error {
    case notFoundIdentifier = "identifierが見つかりません"
    case failedToApiRequest = "APIリクエストに失敗しました"
    case failedToDecode = "デコードに失敗しました"
}
