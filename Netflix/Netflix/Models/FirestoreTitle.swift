//
//  FirestoreTitle.swift
//  Netflix
//
//  Created by Sayaka Alam on 10/1/25.
//

import Foundation

struct FirestoreTitle: Codable {
    let id: Int
    let userId: String
    let mediaType: String?
    let originalName: String?
    let originalTitle: String?
    let posterPath: String?
    let overview: String?
    let voteCount: Int
    let releaseDate: String?
    let voteAverage: Double
}

