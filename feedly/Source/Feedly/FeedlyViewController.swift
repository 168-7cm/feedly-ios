//
//  FeedlyViewController.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/27.
//

import UIKit
import RxSwift
import RxCocoa
import Toast
import GoogleMobileAds

// MARK:- Class
final class FeedlyViewController: ViewControllerBase {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private var viewModel: FeedlyViewModelType!

    // 広告表示用のプロパティ
    private var nativeAdLoader: GADAdLoader!
    private var nativeAds = [GADNativeAd]()
    private let NativeADRelay = PublishRelay<[GADNativeAd]>()

    @IBOutlet weak var feedListTableView: UITableView!
    @IBOutlet weak var showNextFeedButton: UIBarButtonItem!

    override func viewDidLoad() {
        setupViewModel()
        setupTableView()
        bind()
    }

    // MARK: - Private Function

    private func setupViewModel() {

        // ViewModelの初期化
        viewModel = FeedlyViewModel(nativeAdObservable: NativeADRelay.asObservable(), authApi: FeedlyAuthModel(), StreamApi: FeedlyStreamModel())

        // 初回取得分のフィードを表示する
        viewModel?.inputs.getFeeds()
        setupNativeAD()
    }

    private func setupTableView() {
        feedListTableView.register(R.nib.feedCell)
        feedListTableView.refreshControl = refreshControl
    }

    private func bind() {

        // 一覧データをUITableViewにセットする処理
        viewModel?.outputs.feedItems.bind(to: feedListTableView.rx.items(cellIdentifier: R.reuseIdentifier.feedCell.identifier, cellType: FeedCell.self)) { [weak self] (index, feedItem, cell) in
            if let feedItem = feedItem as? FeedItem {
                cell.setup(feedItem: feedItem, index: index)
            } else {
                cell.setup(feedItem: FeedItem(originId: "", title: "広告広告広告広告", author: "", published: Date(), visual: Visual(url: "")), index: index)
            }
        }.disposed(by: disposeBag)

        // UITableViewに配置されたセルをタップした場合の処理
        feedListTableView.rx.modelSelected(FeedItem.self).subscribe( onNext: { [weak self] feed in
            // 画面遷移
            print("didTapped\(feed)")
        }).disposed(by: disposeBag)

        // UITableViewをいちばん下までスクロールした場合
        feedListTableView.rx.willDisplayCell.subscribe( onNext: { [weak self] feed in

            guard let self = self else { return }

            let lastSectionIndex = self.feedListTableView.numberOfSections - 1
            let lastRowIndex = self.feedListTableView.numberOfRows(inSection: lastSectionIndex) - 1
            let showsTableFooterView = feed.indexPath.section ==  lastSectionIndex && feed.indexPath.row == lastRowIndex
            if showsTableFooterView {
                self.setupNativeAD()
                self.viewModel.inputs.getFeeds()
            }
        }).disposed(by: disposeBag)

        // RefreshControlを読んだ場合の処理
        refreshControl.rx.controlEvent(.valueChanged).asDriver().drive(onNext: { [weak self] _ in
            self?.setupNativeAD()
            self?.viewModel?.inputs.resetContinuation()
            self?.viewModel?.inputs.getFeeds()
            self?.refreshControl.endRefreshing()
        }).disposed(by: disposeBag)

        // 追加取得する処理
        showNextFeedButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.inputs.getFeeds()
            self?.setupNativeAD()
        }).disposed(by: disposeBag)

        // エラーの場合
        viewModel?.outputs.errorText.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] errorMessage in
            self?.showToast(errorMessage: errorMessage)
        }).disposed(by: disposeBag)

        // インジケーターを表示/非表示にする処理
        viewModel?.outputs.loading.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] in
            self?.showIndicator(isShow: $0)
        }).disposed(by: disposeBag)
    }
}

// MARK: - Extension - GADNativeAdLoaderDelegate

extension FeedlyViewController: GADNativeAdLoaderDelegate {

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
        self.NativeADRelay.accept(nativeAds)
    }
}
