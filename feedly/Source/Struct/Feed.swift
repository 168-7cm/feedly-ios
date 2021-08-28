//
//  FeedlyDataSource.swift
//  feedly
//
//  Created by kou yamamoto on 2021/08/27.
//
import Foundation

struct Feed: Codable {
    let continuation: String
    let items: [FeedItem]
}

struct FeedItem: Codable {
    let originId: String
    let title: String
    let author: String
    let published: Date
    let visual: Visual?
}

struct Visual: Codable {
    let url: String
}
