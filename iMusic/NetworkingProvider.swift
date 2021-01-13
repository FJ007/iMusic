//
//  NetworkingProvider.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import Foundation
import UIKit

final class NetworkingProvider {
    
    static let shared = NetworkingProvider()
    
    var imageCache = NSCache<AnyObject, AnyObject>() /// Guardamos las imagenes en cache para optimizar y tener una respuesta más rápida
    var searchResults: SearchResults?
    var searchAlbum: SearchAlbum?
    
    let dispatchGroup = DispatchGroup() /// Para notificar cuando ha terminado de realizar la llamada al servidor o red

    // MARK: - Funcs
    /// Realizamos una petición GET para obtener un JSON de tipo Artista según el valor de búsqueda 
    func fetchArtist(for name: String, failure: @escaping () -> Void) {
        if let url = URL(string: DataAPI.fetchRequest(value: name)) {
            dispatchGroup.enter()
            loadNetworkData(url: url) { data in
                let dataJSON = try? JSONDecoder().decode(SearchResults.self, from: data)
                if let result = dataJSON {
                    self.searchResults = result
                    self.dispatchGroup.leave()
                }
            }
        } else {
            print("ERROR URL!")
            failure()
        }
    }
    
    /// Realizamos una petición GET para obtener un JSON de tipo Album según el ID de la colección del artista buscado
    func fetchTracksByAlbum(id: Int, failure: @escaping () -> Void) {
        if let url = URL(string: DataAPI.fetchTracksByAlbumID(id: id)) {
            dispatchGroup.enter()
            loadNetworkData(url: url) { data in
                let dataJSON = try? JSONDecoder().decode(SearchAlbum.self, from: data)
                if let result = dataJSON {
                    self.searchAlbum = result
                    self.dispatchGroup.leave()
                }
            }
        } else {
            print("ERROR URL!")
            failure()
        }
    }
}

// MARK: - Utils
extension NetworkingProvider {
    
    /// Función estandar para obtener el data de una URL
    func loadNetworkData (url: URL, completion: @escaping (Data) -> Void) {
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {
                    print("ERROR: \(error)")
                }
                return
            }
            if response.statusCode == 200 {
                completion(data)
                self.dispatchGroup.leave()
            } else {
                print("ERROR STATUS: \(response.statusCode)")
            }
        }.resume()
    }
    
    /// Función complementaria al "networkData" para obtener la imagen desde una URL  a través del data
    func loadNetworkImage (url: URL, completion: @escaping (UIImage) -> Void) {
        if let imageCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            completion(imageCache) /// Buscamos en nuestra caché
            return
        }
        loadNetworkData(url: url) { data in
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageCache.setObject(image, forKey: url as AnyObject) /// Guardamos en nuestra caché
                    completion(image)
                }
            } else {
                /// Si no hay imagen disponible, asignamos una propia
                DispatchQueue.main.sync {
                    completion(UIImage(named: "image-no-available")!)
                }
            }
        }
    }
}
