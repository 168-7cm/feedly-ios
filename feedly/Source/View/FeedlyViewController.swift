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

// MARK:- Class
final class FeedlyViewController: ViewControllerBase {

    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private var viewModel: FeedlyViewModelProtocol!

    // MARK: IBOutlets
    @IBOutlet weak var feedListTableView: UITableView!
    @IBOutlet weak var showNextFeedButton: UIBarButtonItem!

    // MARK: Life-Cycle Methods
    override func viewDidLoad() {
        setupViewModel()
        setupTableView()
        bind()
    }

    // MARK: Privte Methods
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

        // エラーの場合
        viewModel?.errorText.asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { [weak self] errorMessage in
            self?.showToast(errorMessage: errorMessage)
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

        // UITableViewに配置されたセルをタップした場合の処理
        feedListTableView.rx.modelSelected(FeedItem.self).subscribe( onNext: { [weak self] feed in
            // 画面遷移
            print("didTapped\(feed)")
        }).disposed(by: disposeBag)

        // UITableViewをいちばん下までスクロールした場合
        feedListTableView.rx.willDisplayCell.subscribe( onNext: { [weak self] feed in
            let lastSectionIndex = ((self?.feedListTableView.numberOfSections)!) - 1
            let lastRowIndex = (self?.feedListTableView.numberOfRows(inSection: lastSectionIndex))! - 1
            let showsTableFooterView = feed.indexPath.section ==  lastSectionIndex && feed.indexPath.row == lastRowIndex
            if showsTableFooterView {
                self?.viewModel.getFeeds()
            }
        }).disposed(by: disposeBag)
    }
}
