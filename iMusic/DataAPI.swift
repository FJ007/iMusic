//
//  DataAPI.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import Foundation

struct DataAPI {
    static let mainURL = "https://itunes.apple.com/"
    
    // MARK: - Funcs
    /// Búsqueda de cualquier tipo de contenido, por defecto música
    static func fetchRequest(type: Type = .search, value: String, limit: Int = 25, media: ContentMedia = .music) -> String {
        let valueToSearch = value.replacingOccurrences(of: " ", with: "+")
                                 .folding(options: .diacriticInsensitive, locale: .current) /// Quitamos los acentos
        
        return "\(DataAPI.mainURL)\(type)?term=\(valueToSearch)&limit=\(limit)&media=\(media)"
    }
    
    /// Búsqueda de tracks que tiene un álbum por ID
    static func fetchTracksByAlbumID(id: Int, entity: EntityMusic = .song) -> String {
        "\(DataAPI.mainURL)\(Type.lookup.rawValue)?id=\(id)&entity=\(entity)"
    }
}

/// Tipo de búsqueda
enum Type: String {
    case search
    case lookup
}

/// Tipo de contenido
enum ContentMedia: String {
    case movie
    case podcast
    case music
    case musicVideo
    case caseaudiobook
    case shortFilm
    case tvShow
    case software
    case ebook
    case all
}

enum EntityMusic: String {
    case usicArtist
    case musicTrack
    case album
    case musicVideo
    case mix
    case song
}


// MARK: - Info API

// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
// Default Limit API = 50
// Espacios = +


/*
 Search Examples:
 
 To search for all Jack Johnson audio and video content
 https://itunes.apple.com/search?term=jack+johnson
 To search for all Jack Johnson audio and video content and return only the first 25 items
 https://itunes.apple.com/search?term=jack+johnson&limit=25
 To search for only Jack Johnson music videos
 https://itunes.apple.com/search?term=jack+johnson&entity=musicVideo
 To search for all Jim Jones audio and video content and return only the results from the Canada iTunes Store
 https://itunes.apple.com/search?term=jim+jones&country=ca
*/

/*
 Lookup Examples:
 
 Look up Jack Johnson by iTunes artist ID:
 https://itunes.apple.com/lookup?id=909253
 Look up Jack Johnson by AMG artist ID:
 https://itunes.apple.com/lookup?amgArtistId=468749
 Look up multiple artists by their AMG artist IDs:
 https://itunes.apple.com/lookup?amgArtistId=468749,5723
 Look up all albums for Jack Johnson:
 https://itunes.apple.com/lookup?id=909253&entity=album
*/
