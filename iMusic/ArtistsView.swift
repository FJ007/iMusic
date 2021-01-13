//
//  ViewController.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import UIKit

class ArtistsView: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelInfo: UILabel!
    
    private let reuseIdentifier = "ArtistCell"
    private let segueDetailView = "segueMediaPlayerView"
    private let artists = NetworkingProvider.shared
    private var lastSearch = ""
    
    /// Configuración barra de búsqueda
    let searchController: UISearchController = ({
        let sc = UISearchController(searchResultsController: nil)
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = NSLocalizedString("searchControllerPlaceholder",
                                                     comment: "Tags para realizar una búsqueda")
        sc.searchBar.keyboardType = .default
        sc.searchBar.autocorrectionType = .default
        sc.searchBar.accessibilityIdentifier = "ArtistsViewSearchBar"
        return sc
    })()
    
    /// Testing
    let artistsTest = ArtistsTest()
   
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("titleNavigationController", comment: "Título de nuestra view principal")
        self.navigationController?.navigationBar.accessibilityIdentifier = "InitAppArtistViewNavBar" /// UI Testing
        
        self.labelInfo.isHidden = true
        self.labelInfo.text =  NSLocalizedString("labelInfoArtistsView", comment: "Info al usuario")
        
        setupTableView() /// Configuramos nuestra tableView para poder ser usada
        setupSearchController() /// Configuramos nuestro searchController con el navigationItem
        setupLogoNavigationController() /// Mostramos logo de la app en nuestra NavigationBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueDetailView {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let detailView = segue.destination as! MediaPlayerView
                detailView.artist = (self.artists.searchResults?.results?[indexPath.row])! as Artist
            }
        }
    }
    
    /// Evitamos hacer el segue a  la vista detalle sino hay nada que reproducir
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == segueDetailView {
            guard let indexPath = self.tableView.indexPathForSelectedRow,
                  let _ = self.artists.searchResults?.results?[indexPath.row].previewURL else {
                return false
            }
            return true
        }
        return false
    }
    
    @IBAction func unwindToMediaPlayerView(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    // MARK: - Utils
    fileprivate func setupTableView() {
        self.tableView.register(UINib(nibName: "ArtistViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.accessibilityIdentifier = "InitAppArtistTableView" /// UI Testing
    }
    
    fileprivate func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        
        self.navigationItem.searchController = self.searchController
        self.definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    /// Añadimos logo de nuestra app en la NavigationBar
    fileprivate func setupLogoNavigationController() {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 24,
                                                  height: 24))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        self.navigationItem.titleView?.sizeToFit()
    }
    
    /// Sincronizamos datos de nuestra tableView y actualizamos estados de nuestras views
    fileprivate func reloadDataTableView() {
        self.activityIndicator.startAnimating()
        NetworkingProvider.shared.dispatchGroup.notify(queue: .main) { 
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            
            if self.artists.searchResults?.resultCount != 0 {
                self.labelInfo.isHidden = true
            } else {
                self.labelInfo.isHidden = false
            }
        }
    }
    
    /// Alerta Simple de Notificación al Usuario con botón de  Aceptar
    fileprivate func showAlertViewNotification(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  NSLocalizedString("buttonAlertOK", comment: ""),
                                      style: .default, handler: { _ in
                                        alert.dismiss(animated: true, completion: nil)
                                      }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension ArtistsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: segueDetailView, sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true) /// Comentar linea si queremos tener marcado la celda al cerrar la view del reproductor
    }
}

// MARK: - UITableViewDataSource
extension ArtistsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        artists.searchResults?.results?.count ?? 0
        /// Testing
        //artistsTest.artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ArtistViewCell
        
        if let imageURL = artists.searchResults?.results?[indexPath.row].artworkUrl100 {
            artists.loadNetworkImage(url: imageURL, completion: { image in
                cell.artistImage.clipShapeCircle(image: image)
            })
        }
        cell.artistName.text = artists.searchResults?.results?[indexPath.row].artistName
        cell.trackName.text = artists.searchResults?.results?[indexPath.row].trackName
        cell.genreTrack.text = artists.searchResults?.results?[indexPath.row].primaryGenreName
        
        /// Testing Local Data Debug
        //testDataTableView(cell: cell, row: indexPath.row)
        
        return cell
    }
    
}

// MARK: - UISearchResultsUpdating
extension ArtistsView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            return
        }
        self.lastSearch = text
    }
}

// MARK: - UISearchBarDelegate
extension ArtistsView: UISearchBarDelegate {
    /// Lanzamos nuestra petición GET de búsqueda cuando el usuario pulse "Buscar" en el teclado
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !self.lastSearch.isEmpty {
            NetworkingProvider.shared.fetchArtist(for: self.lastSearch.lowercased()) {
                /// Solo se ejecuta si la URL da error, avisando al usuario con una Alerta.
                self.showAlertViewNotification(title: NSLocalizedString("titleAlertNotURL", comment: ""),
                                               message: NSLocalizedString("messageAlertNotURL", comment: ""))
            }
            self.reloadDataTableView()
        }
    }
}


// MARK: - Testing Debug
extension ArtistsView {
    func testDataTableView(cell: ArtistViewCell, row: Int) {
        if let image = UIImage(named: artistsTest.artists[row].image) {
            cell.artistImage.clipShapeCircle(image: image)
        }
        cell.artistName.text = artistsTest.artists[row].name
        cell.trackName.text = artistsTest.artists[row].trackName
    }
}


