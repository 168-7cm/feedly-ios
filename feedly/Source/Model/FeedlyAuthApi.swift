//
//  FeedlyApi.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/25.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess
import RxSwift

struct AuthResult: Codable {
    let provider: String
    let id: String
    let plan: String
    let scope: String
    let access_token: String
    let token_type: String
    let expires_in: Int
}

protocol FeedlyAuthApiProtocol {
    func apiRequest() -> Single<String>
}

final class FeedlyAuthApi: FeedlyAuthApiProtocol {

    private let baseURL = "https://cloud.feedly.com/v3/auth/token"
    private let refreshToken = "AwSnX-EMirTzNRKw8UTe4Gc7ediCo6BaSNJF7mU0tovmu_smUVeUQC9A_tYW5O-fYwcEG9-UuN5xvbDUHX2samYY-frpv4PVdwXTMUfogz5F9Ko7iksfsUY0boa-91WIeXlUiLco-beFUgR7RhO1644MHbmb8AbYdsOADvLCq3N1g2il4U5-_hlzv3SjUIrEHE5VzsAcUB3tJEGiRaf3nx59oMPqXDY:feedlydev"

    func apiRequest() -> Single<String> {
        return Single<String>.create { single in
            let parameters: Parameters = ["refresh_token": self.refreshToken, "client_id": "feedlydev", "client_secret": "feedlydev", "grant_type": "refresh_token"]
            AF.request(self.baseURL, method: .post, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    if let data = response.data, let AuthResult = try? JSONDecoder().decode(AuthResult.self, from: data) {
                        single(.success(AuthResult.access_token))
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
