//
//  CreateShopViewController.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/02.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateShopViewContrller: ViewControllerBase {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private var viewModel = CreateShopViewModel()

    @IBOutlet weak var createShopButton: UIButton!

    override func viewDidLoad() {
        bindViewModel()
    }

    static func configureWith() -> CreateShopViewContrller {
        let viewController = R.storyboard.createShop.createShop()!
        viewController.viewModel.inputs.configureWith()
        return viewController
    }

    // MARK: - Private Function

    private func bindViewModel() {

        // ショップを作成する場合
        createShopButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel.inputs.createShop()
        }).disposed(by: disposeBag)

        // 作成した場合
        viewModel.outputs.shop.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] shop in
            // ここで親Viewに作成したことを通知したい
        }).disposed(by: disposeBag)

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
