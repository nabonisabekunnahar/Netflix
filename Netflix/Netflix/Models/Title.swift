//
//  Movie.swift
//  Netflix Clone
//
//  Created by Sayaka Alam on 3/1/25.
//



import Foundation

struct TrendingTitleResponse: Codable {
    let results: [Title]
}

struct Title: Codable {
    let id: Int
    let media_type: String?
    let original_name: String?
    let original_title: String?
    let poster_path: String?
    let overview: String?
    let vote_count: Int
    let release_date: String?
    let vote_average: Double
}

/*
import Foundation
struct Title: Codable {
    var id: Int
    var media_type: String?
    var original_name: String?
    var original_title: String?
    var poster_path: String?
    var overview: String?
    var release_date: String?
    var vote_average: Double?
    var vote_count: Int?

    // Initializer for Firestore documents
    init(fromDocument document: [String: Any]) {
        self.id = document["id"] as? Int ?? 0
        self.media_type = document["media_type"] as? String
        self.original_name = document["original_name"] as? String
        self.original_title = document["original_title"] as? String
        self.poster_path = document["poster_path"] as? String
        self.overview = document["overview"] as? String
        self.release_date = document["release_date"] as? String
        self.vote_average = document["vote_average"] as? Double
        self.vote_count = document["vote_count"] as? Int
    }
}

// Model for API response
struct TrendingTitleResponse: Codable {
    let results: [Title]
}
*/
