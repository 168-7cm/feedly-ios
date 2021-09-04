//
//  FirestoreCell.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/29.
//

import UIKit

final class FirestoreCell: UITableViewCell {

    @IBOutlet weak var shopNameLabel: UILabel!

    func configure(shop: Shop) {
        shopNameLabel.text = shop.name
    }
}
