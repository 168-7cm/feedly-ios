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

final class FirestoreViewController: ViewControllerBase {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private var viewModel: FirestoreViewModel!

    // 広告表示用のプロパティ
    private var nativeAdLoader: GADAdLoader!
    private var nativeAds = [GADNativeAd]()
    private let nativeAdRelay = PublishRelay<[GADNativeAd]>()

    @IBOutlet weak var firestoreTableView: UITableView!

    override func viewDidLoad() {
        setupViewModel()
        setupTableView()
        bind()
    }

    // MARK: - Private Function

    private func setupViewModel() {

        // ViewModelの初期化
        viewModel = FirestoreViewModel(nativeAdObservable: nativeAdRelay.asObservable(), firestoreModel: FirestoreShopModel())

        // 初回取得分のフィードを表示する
        viewModel.inputs.createShop()
        viewModel?.inputs.getShops()
        setupNativeAD()
    }

    private func setupTableView() {
        firestoreTableView.register(R.nib.firestoreCell)
        firestoreTableView.refreshControl = refreshControl
        firestoreTableView.tableFooterView = UIView()
    }

    // ViewModelとBindする
    private func bind() {

        // 一覧データをUITableViewにセットする処理
        viewModel?.outputs.shops.bind(to: firestoreTableView.rx.items) { (tableView, row, shop) in

            // shopの場合
            if let shop = shop as? Shop {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.firestoreCell.identifier) as! FirestoreCell
                cell.configure(shop: shop)
                return cell

            // 広告の場合 一旦実装は省略
            } else {
                return UITableViewCell()
            }

        }.disposed(by: disposeBag)

        // RefreshControlを読んだ場合の処理
        refreshControl.rx.controlEvent(.valueChanged).asDriver().drive(onNext: { [weak self] _ in
            self?.setupNativeAD()
            self?.viewModel?.inputs.getShops()
            self?.refreshControl.endRefreshing()
        }).disposed(by: disposeBag)

        // UITableViewに配置されたセルをタップした場合の処理
        firestoreTableView.rx.modelSelected(FirestoreCell.self).subscribe( onNext: { [weak self] shop in
            // 画面遷移
            print("didTapped\(shop)")
        }).disposed(by: disposeBag)
    }
}

// MARK: - Extension - GADNativeAdLoaderDelegate

extension FirestoreViewController: GADNativeAdLoaderDelegate {

    func setupNativeAD() {
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
        self.nativeAdRelay.accept(nativeAds)
    }
}
