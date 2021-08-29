//
//  FeedlyViewController.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/27.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

final class FeedlyViewController: UIViewController {

    @IBOutlet weak var feedListTableView: UITableView!
    @IBOutlet weak var showNextFeedButton: UIBarButtonItem!

    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private var viewModel: FeedlyViewModelProtocol!

    override func viewDidLoad() {
        setupViewModel()
        setupTableView()
        bind()
    }

    private func setupViewModel() {

        // ViewModelの初期化
        viewModel = FeedlyViewModel(authApi: FeedlyAuthApi(), StreamApi: FeedlyStreamApi())

        // 初回取得分のフィードを表示する
        viewModel?.getFeeds()
    }

    private func setupTableView() {
        feedListTableView.register(R.nib.feedCell)
        feedListTableView.refreshControl = refreshControl
    }

    private func bind() {

        // 一覧データをUITableViewにセットする処理
        viewModel?.feedItems.bind(to: feedListTableView.rx.items(cellIdentifier: R.reuseIdentifier.feedCell.identifier, cellType: FeedCell.self)) { [weak self] (index, feedItem, cell) in
            cell.setup(feedItem: feedItem, index: index)
        }.disposed(by: disposeBag)

        // UITableViewに配置されたセルをタップした場合の処理
        feedListTableView.rx.itemSelected.subscribe( onNext: { [weak self] indexPath in
            let feed = self?.viewModel?.feedItems
            print("didTapped\(feed)&\(indexPath)")
        }).disposed(by: disposeBag)

        // エラーの場合
        viewModel?.errorText.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] error in
            self?.showToast(error: error)
        }).disposed(by: disposeBag)

        // インジケーターを表示/非表示にする処理
        viewModel?.loading.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] in
            self?.showIndicator(isShow: $0)
        }).disposed(by: disposeBag)

        // RefreshControlを読んだ場合の処理
        refreshControl.rx.controlEvent(.valueChanged).asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.resetContinuation()
            self?.viewModel?.getFeeds()
            self?.refreshControl.endRefreshing()
        }).disposed(by: disposeBag)

        // 追加取得する処理
        showNextFeedButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.getFeeds()
        }).disposed(by: disposeBag)
    }
}

extension FeedlyViewController {

    private func showIndicator(isShow: Bool) {
        switch isShow {
        case true:
            self.view.makeToastActivity(.center)
        case false:
            self.view.hideToastActivity()
        }
    }

    private func showToast(error: String) {
        self.view.makeToast(error, duration: 1.0, position: .bottom)
    }
}
