//
//  TabBarController.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/06.
//

import UIKit

final class TabBarController: UITabBarController {


    override func viewDidLoad() {
        let viewControllers = [feedlyViewControllerInstansiate(), firestoreViewControllerINstansiate()]
        self.setViewControllers(viewControllers, animated: true)
        self.setupTabbarController(viewControllers: viewControllers)
    }

    private func feedlyViewControllerInstansiate() -> UINavigationController {
        let viewController = FeedlyViewController.configureWith()
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    private func firestoreViewControllerINstansiate() -> UINavigationController {
        let viewController = ShopViewController.configuredWith()
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    private func setupTabbarController(viewControllers: [UIViewController]) {
        viewControllers.enumerated().forEach { (index, viewController) in
            switch index {
            case 0:
                setupTabbarController(viewController: viewController, selectedImage: R.image.eiSettings()!, unSelectedImage: R.image.eiSettings()!, title: "記事")
            case 1:
                setupTabbarController(viewController: viewController, selectedImage: R.image.eiSettings()!, unSelectedImage: R.image.eiSettings()!, title: "店")
            default:
                setupTabbarController(viewController: viewController, selectedImage: R.image.eiSettings()!, unSelectedImage: R.image.eiSettings()!, title: "最新情報")
            }
        }
    }

    // タブバーのアイコンサイズを設定
    private func setupTabbarController(viewController: UIViewController,selectedImage: UIImage, unSelectedImage: UIImage, title: String) {
        viewController.tabBarItem.selectedImage = selectedImage.resize(size: .init(width: 22, height: 22))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = unSelectedImage.resize(size: .init(width: 22, height: 22))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
    }
}

