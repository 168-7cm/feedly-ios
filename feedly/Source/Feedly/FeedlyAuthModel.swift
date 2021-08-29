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

protocol FeedlyAuthModelProtocol {
    func apiRequest() -> Single<String>
}

final class FeedlyAuthModel: FeedlyAuthModelProtocol {

    private let baseURL = "https://cloud.feedly.com/v3/auth/token"
    private let refresh_token = "AwSnX-EMirTzNRKw8UTe4Gc7ediCo6BaSNJF7mU0tovmu_smUVeUQC9A_tYW5O-fYwcEG9-UuN5xvbDUHX2samYY-frpv4PVdwXTMUfogz5F9Ko7iksfsUY0boa-91WIeXlUiLco-beFUgR7RhO1644MHbmb8AbYdsOADvLCq3N1g2il4U5-_hlzv3SjUIrEHE5VzsAcUB3tJEGiRaf3nx59oMPqXDY:feedlydev"

    func apiRequest() -> Single<String> {

        // APIにリクエストする際に必要なパラメーターを定義する
        let parameters: Parameters = [
            "refresh_token": refresh_token,
            "client_id": "feedlydev",
            "client_secret": "feedlydev",
            "grant_type": "refresh_token"
        ]

        return Single<String>.create { single in
            AF.request(self.baseURL, method: .post, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    if let data = response.data, let json = try? JSON(data: data), let access_token = json["access_token"].string {
                        single(.success(access_token))
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
