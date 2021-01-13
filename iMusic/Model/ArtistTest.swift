//
//  ArtistTest.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import Foundation

struct ArtistTest {
    let name: String
    let trackName: String
    let image: String
    let genre: String
    let url: String
    let mediaTrack: String? /// Reprodución del archivo
}

final class ArtistsTest {
    var artists: [ArtistTest]
    
    init() {
       let philCollins = ArtistTest(name: "Phil Collins",
                                    trackName: "In the Air Tonight",
                                    image: "phil-collins",
                                    genre: "film",
                                    url: "https://music.apple.com/es/artist/phil-collins/153718",
                                    mediaTrack: "sample-phil-collins")
        
        let philCollins2 = ArtistTest(name: "Phil Collins",
                                     trackName: "In the Air Tonight",
                                     image: "phil-collins",
                                     genre: "dance",
                                     url: "https://music.apple.com/es/artist/phil-collins/153718",
                                     mediaTrack: "sample-phil-collins")
        
        let philCollins3 = ArtistTest(name: "Phil Collins",
                                     trackName: "In the Air Tonight",
                                     image: "phil-collins",
                                     genre: "pop",
                                     url: "https://music.apple.com/es/artist/phil-collins/153718",
                                     mediaTrack: "sample-phil-collins")
        
        artists = [philCollins, philCollins2, philCollins3]
    }
}

/// Variable Global para Testing
let artistsTest = ArtistsTest()
