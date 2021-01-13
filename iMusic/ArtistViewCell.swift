//
//  ArtistViewCell.swift
//  iMusic
//
//  Created by Javier Fernández on 5/1/21.
//

import UIKit

class ArtistViewCell: UITableViewCell {

    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var genreTrack: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    
    // MARK: - Lifecycle
    /// Asignamos valores por defecto mientras carga los datos JSON de la red
    override func awakeFromNib() {
        super.awakeFromNib()
        self.trackName.text = ""
        self.artistName.text = ""
        if let image =  UIImage(named: "placeholder") {
            self.artistImage.clipShapeCircle(image: image)
        }
    }
    
    /// Reseteamos nuestros outlet para optimizar recursos
    override func prepareForReuse() {
        super.prepareForReuse()
        self.trackName.text = nil
        self.artistName.text = nil
        self.artistImage.image = nil
    }
    
    // MARK: - Funcs
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
