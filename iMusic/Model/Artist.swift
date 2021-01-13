//
//  Artist.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import Foundation

// MARK: - SearchResults
struct SearchResults: Codable {
    let resultCount: Int
    let results: [Artist]?
}

// MARK: - Artist
struct Artist: Codable {
    let wrapperType: String?
    let kind: String?
    let artistID: Int?
    let collectionID: Int?
    let trackID: Int?
    
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    let collectionCensoredName: String?
    let trackCensoredName: String?
    let collectionArtistName: String?
    
    let artistViewURL: String?
    let collectionViewURL: String?
    let trackViewURL: String?
    let previewURL: String? /// Reprodución del archivo
    
    let artworkUrl30: URL?
    let artworkUrl60: URL?
    let artworkUrl100: URL?
    
    let collectionPrice: Double?
    let trackPrice: Double?
    let releaseDate: String?
    let collectionExplicitness: String?
    let trackExplicitness: String?
    
    let discCount: Int?
    let discNumber: Int?
    let trackCount: Int?
    let trackNumber: Int?
    let trackTimeMillis: Int?
    
    let country: String?
    let currency: String?
    let primaryGenreName: String?
    let isStreamable: Bool?
    let collectionArtistID: Int?
    let collectionArtistViewURL: String?
    
    enum CodingKeys: String, CodingKey {
        case wrapperType
        case kind
        case artistID = "artistId"
        case collectionID = "collectionId"
        case trackID = "trackId"
        
        case artistName
        case collectionName
        case trackName
        case collectionCensoredName
        case trackCensoredName
        case collectionArtistName
        
        case artistViewURL = "artistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case trackViewURL = "trackViewUrl"
        case previewURL = "previewUrl"
        
        case artworkUrl30
        case artworkUrl60
        case artworkUrl100
        
        case collectionPrice
        case trackPrice
        case releaseDate
        case collectionExplicitness
        case trackExplicitness
        
        case discCount
        case discNumber
        case trackCount
        case trackNumber
        case trackTimeMillis
        
        case country
        case currency
        case primaryGenreName
        case isStreamable
        case collectionArtistID = "collectionArtistId"
        case collectionArtistViewURL = "collectionArtistViewUrl"
    }
}

