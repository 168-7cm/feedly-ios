//
//  FeedlyApi.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/25.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift

protocol FeedlyStreamModelProtocol {
    func apiRequest<T: Codable>(access_token: String, continuation: String?) -> Single<T>
}

final class FeedlyStreamModel: FeedlyStreamModelProtocol {

    private let identifier = Bundle.main.bundleIdentifier!
    private let baseURL = "https://cloud.feedly.com/v3/streams/contents"
    private let streamId = "user/c9d12512-16d0-4c11-a7d4-8bd7d6a9d1eb/category/8c926a9a-f3b1-4579-b972-6f23a442ecb5"

    func apiRequest<Feed: Codable>(access_token: String, continuation: String?) -> Single<Feed> {

        let headers: HTTPHeaders = ["Authorization": "OAuth \(access_token)"]
        var parameters: Parameters = ["streamId": self.streamId]
        if let continuation = continuation {
            parameters["continuation"] = continuation
        }

        return Single<Feed>.create { single in
            AF.request(self.baseURL, method: .get, parameters: parameters, headers: headers).responseJSON { response in
                switch response.result {
                case .success:
                    if let data = response.data, let feed = try? JSONDecoder().decode(Feed.self, from: data) {
                        single(.success(feed))
                    } else {
                        single(.failure(CustomError.failedToDecode))
                    }
                case .failure:
                    single(.failure(CustomError.failedToApiRequest))
                }
            }
            return Disposables.create()
        }
    }
}
