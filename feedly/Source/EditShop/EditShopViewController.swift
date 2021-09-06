//
//  EditShopViewController.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/06.
//

import UIKit
import RxSwift
import RxCocoa

final class EditShopViewController: ViewControllerBase {


    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private var viewModel: EditShopViewModelType = EditShopViewModel()

    @IBOutlet weak var shopNameTextView: PlaceTextView!

    override func viewDidLoad() {
        bindViewModel()
    }

    static func configureWith(shop: Shop) -> EditShopViewController {
        let viewController = R.storyboard.editShop.editShop()!
        viewController.viewModel.inputs.configureWith(shop: shop)
        return viewController
    }

    // MARK: - Private Function

    private func bindViewModel() {

        // エラーの場合の処理
        viewModel.outputs.error.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] error in
            self?.showToast(errorMessage: error.localizedDescription)
        }).disposed(by: disposeBag)

        // インジケーターを表示/非表示にする処理
        viewModel.outputs.loading.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] loading in
            self?.showIndicator(isShow: loading)
        }).disposed(by: disposeBag)
    }
}
