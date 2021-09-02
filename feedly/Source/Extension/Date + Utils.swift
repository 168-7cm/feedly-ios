//
//  String + Utils.swift
//  feedly
//
//  Created by kou yamamoto on 2021/09/02.
//

import Foundation

extension Date {

    // MARK: Methods
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: self)
    }
}
