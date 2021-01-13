//
//  MediaPlayerView.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import UIKit
import AVFoundation
import AVKit

class MediaPlayerView: UIViewController {
    
    @IBOutlet weak var buttonClosed: UIButton!
    @IBOutlet weak var backgroundViewMediaPlayer: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTrackName: UILabel!
    @IBOutlet weak var labelArtistName: UILabel!
    
    @IBOutlet weak var labelCurrentMinutes: UILabel!
    @IBOutlet weak var labelRemainingMinutes: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var sliderVolume: UISlider!
    
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonOptions: UIButton!
    
    var artist: Artist!
    var album = [Artist]()
    var audioPlayer = AVAudioPlayer()
    var dataAudio: Data?
    
    var imageSymbolConfiguration: UIImage.SymbolConfiguration!
    var currentTrack = 0
    
    // MARK: - Actions
    /// Canción Anterior, sino hay más deshabiitamos el botón
    @IBAction func previousTrack(_ sender: UIButton) {
        currentTrack -= 1
        self.buttonNext.isEnabled = true
        
        if currentTrack >= album.startIndex {
            if let urlString = album[currentTrack].previewURL {
                self.updateAVPlayerTrack(urlString)
            }
            if currentTrack == album.startIndex {
                self.buttonPrevious.isEnabled = false
                currentTrack = album.startIndex
            } else {
                self.buttonPrevious.isEnabled = true
            }
        } else {
            self.buttonPrevious.isEnabled = false
        }
    }
    
    /// Canción Siguiente, sino hay más deshabiitamos el botón
    @IBAction func nextTrack(_ sender: UIButton) {
        currentTrack += 1
        self.buttonPrevious.isEnabled = true
        
        if currentTrack < album.endIndex {
            if let urlString = album[currentTrack].previewURL {
                self.updateAVPlayerTrack(urlString)
            }
            if currentTrack == album.endIndex {
                self.buttonNext.isEnabled = false
                currentTrack = album.endIndex
            } else {
                self.buttonNext.isEnabled = true
            }
        } else {
            self.buttonNext.isEnabled = false
        }
    }

    /// Retroceder -15s
    @IBAction func backwardTrack(_ sender: UIButton) {
        self.audioPlayer.currentTime -= 15
    }
    
    /// Avanzar +15s
    @IBAction func forwardTrack(_ sender: UIButton) {
        self.audioPlayer.currentTime += 15
    }
    
    /// Reiniciar canción
    @IBAction func resetTrack(_ sender: UIButton) {
        if !audioPlayer.isPlaying {
            self.buttonPlayPause.setImage(UIImage(systemName: "pause.fill",
                                                  withConfiguration: self.imageSymbolConfiguration), for: .normal)
            self.setupTimerAVPlayer()
        }
        self.audioPlayer.currentTime = 0
        self.progressView.progress = 0
        
        self.audioPlayer.stop()
        self.audioPlayer.play()
    }
    
    /// Play/Pause
    @IBAction func playTrack(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            self.buttonPlayPause.setImage(UIImage(systemName: "play.fill",
                                           withConfiguration: imageSymbolConfiguration), for: .normal)
        } else {
            audioPlayer.play()
            self.buttonPlayPause.setImage(UIImage(systemName: "pause.fill",
                                           withConfiguration: imageSymbolConfiguration), for: .normal)
        }
        self.setupTimerAVPlayer()
    }
    
    /// Controlamos el volumen con el slider
    @IBAction func volumeTrack(_ sender: UISlider) {
        self.audioPlayer.volume = self.sliderVolume.value
    }
    
    /// AirPlay
    @IBAction func showAirPlay(_ sender: UIButton) {
        // TODO: Funcionalidad de AirPlay Audio
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Mostramos UIMenu
        self.buttonOptions.addAction(UIAction(handler: { _ in }), for: .touchUpInside)
        self.buttonOptions.showsMenuAsPrimaryAction = true
        self.buttonOptions.menu = self.setupUIMenu()
        
        /// Valores por defecto
        self.progressView.progress = 0.0
        self.sliderVolume.value = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupAppearance() /// Apariencia de UI
        if let previewURL = artist.previewURL {
            self.setupAVPlayer(url: previewURL) /// Configuramos AudioPlayer y preparamos nuestro archivo de audio descargado
        }
        self.setupDataUI() /// Sincronizamos datos de nuestro Artista con la vista
        self.getAllTracksByAlbum()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.audioPlayer.stop()
    }
    
    // MARK: - Funcs
    /// Configuramos AVPlayer y realizamos la llamada a red.
    fileprivate func setupAVPlayer(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        /// Preparamos nuestra session de audio para ser reproducida
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("ERROR: \(error)")
        }
        /// Realizamos nuestra petición GET para obtener nuestro audio a través de la URL
        NetworkingProvider.shared.loadNetworkData(url: url) { data in
            self.audioPlayer = try! AVAudioPlayer(data: data)
            self.audioPlayer.prepareToPlay()
            DispatchQueue.main.sync {
                self.audioPlayer.volume = self.sliderVolume.value
            }
        }
    }
    
    /// Obtenemos todas las canciones del artista según su ID
    fileprivate func getAllTracksByAlbum() {
        if let collectionID = artist.collectionArtistID {
            NetworkingProvider.shared.fetchTracksByAlbum(id: collectionID) {
                self.buttonNext.isEnabled = false
                self.buttonPrevious.isEnabled = false
            }
            if let results = NetworkingProvider.shared.searchResults?.results {
                for result in results {
                    album.append(result)
                }
            }
        }
        if album.isEmpty {
            self.buttonPrevious.isEnabled = false
            self.buttonNext.isEnabled = false
        } else {
            self.buttonPrevious.isEnabled = true
            self.buttonNext.isEnabled = true
        }
    }
    
    /// Actualiza la view al avanzar/retroceder canción, reproduciendo el nuevo audio
    fileprivate func updateAVPlayerTrack(_ urlString: String) {
        self.audioPlayer.stop()
        self.setupAVPlayer(url: urlString)
        NetworkingProvider.shared.dispatchGroup.notify(queue: .main) {
            self.audioPlayer.play()
        }
        self.labelArtistName.text = self.album[currentTrack].artistName
        self.labelTrackName.text = self.album[currentTrack].trackName
        if let imageURL = self.album[currentTrack].artworkUrl100 {
            NetworkingProvider.shared.loadNetworkImage(url: imageURL, completion: { image in
                self.imageView.image = image
            })
        }
    }
    
    /// Mostramos Menú de opciones: compartir, más info, copiar
    fileprivate func setupUIMenu() -> UIMenu {
        let menu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("titleActionCopyAlertOptions", comment: "Copiar link"),
                     image: UIImage(systemName: "doc.on.doc")) { (action) in
                
                if let url = URL(string: self.artist.artistViewURL ?? DataAPI.mainURL) {
                    UIPasteboard.general.string = url.absoluteString
                }
            },
            UIAction(title: NSLocalizedString("titleActionInfoAlertOptions", comment: "Más info"),
                     image: UIImage(systemName: "info.circle")) { (action) in
                
                if let url = URL(string: self.artist.artistViewURL ?? DataAPI.mainURL) {
                    UIApplication.shared.open(url)
                }
            },
            UIAction(title: NSLocalizedString("titleActionShareAlertOptions", comment: "Compartir"),
                     image: UIImage(systemName: "square.and.arrow.up")) { (action) in
                
                if let url = URL(string: (self.currentTrack == 0 ? self.artist.previewURL :         self.album[self.currentTrack].previewURL ?? self.artist.artistViewURL) ?? DataAPI.mainURL) {
                    let items = [url]
                    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityVC.popoverPresentationController?.sourceView = action.sender as? UIView
                        activityVC.popoverPresentationController?.permittedArrowDirections = .unknown
                    }
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        ])
        return menu
    }
    
    /// Sincronizamos datos del modelo con la vista
    fileprivate func setupDataUI() {
        self.labelArtistName.text = self.artist.artistName
        self.labelTrackName.text = self.artist.trackName
        if let url = self.artist.artworkUrl100 {
            NetworkingProvider.shared.loadNetworkImage(url: url, completion: { image in
                self.imageView.image = image
            })
        }
    }
    
    // MARK: - Utils
    /// Personalización de las vistas de nuestra View
    fileprivate func setupAppearance() {
        self.backgroundViewMediaPlayer.frame = CGRect(x: 0, y: 0,
                                                      width: UIScreen.main.bounds.width,
                                                      height: UIScreen.main.bounds.height * 0.30)
        AppearanceCustom.setCornerRadius(to: self.backgroundViewMediaPlayer, cornerRadius: 12)
        AppearanceCustom.setShadow(to: [self.backgroundViewMediaPlayer],
                                   shadowColor: UIColor.black.cgColor,
                                   shadowOffset: CGSize(width: 5, height: 5),
                                   shadowRadius: 10,
                                   shadowOpacity: 0.9)
        
        self.buttonClosed.alpha = 0.9
        AppearanceCustom.setShadow(to: [self.buttonClosed],
                                   shadowColor: UIColor.black.cgColor,
                                   shadowOffset: CGSize(width: 1, height: 1),
                                   shadowRadius: 1.0,
                                   shadowOpacity: 0.5)
        
        self.imageSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        self.buttonPrevious.setImage(UIImage(systemName: "backward.fill",
                                      withConfiguration: self.imageSymbolConfiguration), for: .normal)
        
        self.buttonNext.setImage(UIImage(systemName: "forward.fill",
                                  withConfiguration: self.imageSymbolConfiguration), for: .normal)
        
        self.buttonPlayPause.setImage(UIImage(systemName: "play.fill",
                                       withConfiguration: self.imageSymbolConfiguration), for: .normal)
    }
    
    // MARK: - Timer Media
    /// Temporizador para mostrar tiempo actual, restante y barra de progreso
    fileprivate func setupTimerAVPlayer() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self,
                             selector: #selector(currentTime), userInfo: nil, repeats: true) /// Tiempo Actual
        Timer.scheduledTimer(timeInterval: 1.0, target: self,
                             selector: #selector(remainingTime), userInfo: nil, repeats: true) /// Tiempo Restante
        Timer.scheduledTimer(timeInterval: 1.0, target: self,
                             selector: #selector(progessViewTime), userInfo: nil, repeats: true) /// Barra Progreso
    }
    
    @objc
    /// Hacemos la conversion del tiempo actual de la canción y lo mostramos con un formato específico en nuestro view
    fileprivate func currentTime() {
        let currentTime = Int(self.audioPlayer.currentTime)
        let minutes = currentTime / 60
        let seconds = currentTime - minutes * 60
        
        self.labelCurrentMinutes.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc
    /// Hacemos la conversion del tiempo restante de la canción y lo mostramos con un formato específico en nuestro view
    fileprivate func remainingTime() {
        let remaining = Int(self.audioPlayer.duration - self.audioPlayer.currentTime)
        let minutes = remaining / 60
        let seconds = remaining - minutes * 60
        
        self.labelRemainingMinutes.text = String(format: "-%02d:%02d", minutes, seconds)
    }
    
    @objc
    /// Actualizamos la barra de progreso
    fileprivate func progessViewTime() {
        self.progressView.progress = Float(self.audioPlayer.currentTime) / Float(self.audioPlayer.duration)
    }
}


