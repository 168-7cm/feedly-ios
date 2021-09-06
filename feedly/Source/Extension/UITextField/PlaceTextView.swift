//
//  PlaceTextView.swift
//  Bish
//
//  Created by kou yamamoto on 2021/07/23.
//

import UIKit
import SnapKit

// MARK:- Class
final class PlaceTextView: UITextView {

    // MARK: Properties
    var placeHolder: String = "" {
        willSet {
            self.placeHolderLabel.text = newValue
            self.placeHolderLabel.sizeToFit()
        }
    }

    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = self.font
        label.textColor = .lightGray
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        return label
    }()

    // MARK: Life-Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged), name: UITextView.textDidChangeNotification, object: nil)

        placeHolderLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).inset(7)
            make.bottom.equalTo(self.snp.bottom).inset(7)
            make.leading.equalTo(self.snp.leading).inset(5)
            make.trailing.equalTo(self.snp.trailing).inset(5)
        }
    }

    // MARK: Methods
    @objc private func textDidChanged() {
        let shouldHidden = self.placeHolder.isEmpty || !self.text.isEmpty
        self.placeHolderLabel.alpha = shouldHidden ? 0 : 1
    }
}
