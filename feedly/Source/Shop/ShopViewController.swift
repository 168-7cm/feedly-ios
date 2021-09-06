//
//  FirebaseViewController.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/29.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMobileAds

final class ShopViewController: ViewControllerBase {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private let viewModel: ShopViewModelType = ShopViewModel()

    // 広告表示用のプロパティ
    private var nativeAdLoader: GADAdLoader!
    private var nativeAds = [GADNativeAd]()
    private let nativeAdsRelay = PublishRelay<[GADNativeAd]>()

    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var addShopButton: UIBarButtonItem!

    override func viewDidLoad() {
        setupTableView()
        bind()
        // 初回取得分のフィードを表示する
        viewModel.inputs.getShops(nativeAdsObserbavle: self.nativeAdsRelay.asObservable())
        setupNativeAds()
    }

    // MARK: - Private Function

    // VCの初期化
    static func configuredWith() -> ShopViewController {
        let viewController = R.storyboard.shop.shop()!
        viewController.viewModel.inputs.configureWith()
        return viewController
    }

    private func goToCreateShop() {
        let viewController = CreateShopViewContrller.configureWith()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    private func setupTableView() {
        shopTableView.register(R.nib.shopCell)
        shopTableView.refreshControl = refreshControl
        shopTableView.tableFooterView = UIView()
    }

    // ViewModelとBindする
    private func bind() {

        // ボタンタップ
        addShopButton.rx.tap.subscribe( { [weak self] _ in
            self?.viewModel.inputs.createShopButtonDidTapped()
        }).disposed(by: disposeBag)

        // 画面遷移？？
        viewModel.outputs.gotoCreateShop.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] _ in
            self?.goToCreateShop()
        }).disposed(by: disposeBag)

        // 一覧データをUITableViewにセットする処理
        viewModel.outputs.shops.bind(to: shopTableView.rx.items) { (tableView, row, shop) in
            switch shop {
            case let shop as Shop:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.shopCell.identifier) as! ShopCell
                cell.configure(shop: shop)
                return cell
            default:
                return UITableViewCell()
            }
        }.disposed(by: disposeBag)

        // RefreshControlを読んだ場合の処理
        refreshControl.rx.controlEvent(.valueChanged).asDriver().drive(onNext: { [weak self] _ in
            self?.setupNativeAds()
            self?.viewModel.inputs.getShops(nativeAdsObserbavle: self?.nativeAdsRelay.asObservable())
            self?.refreshControl.endRefreshing()
        }).disposed(by: disposeBag)

        // UITableViewに配置されたセルをタップした場合の処理
        shopTableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.viewModel.inputs.didSelectedShop(indexPath: indexPath)
        }).disposed(by: disposeBag)

        viewModel.outputs.loading.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] loading in
            self?.showIndicator(isShow: loading)
        }).disposed(by: disposeBag)
    }
}

// MARK: - Extension - GADNativeAdLoaderDelegate

extension ShopViewController: GADNativeAdLoaderDelegate {

    func setupNativeAds() {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5
        nativeAdLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511", rootViewController: self, adTypes: [.native], options: [multipleAdsOptions])
        nativeAdLoader.delegate = self
        nativeAdLoader.load(GADRequest())
    }

    // 成功した時
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAds.append(nativeAd)
    }

    // 失敗した時
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {

    }

    //広告のリクエストが終了
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        self.nativeAdsRelay.accept(nativeAds)
    }
}
