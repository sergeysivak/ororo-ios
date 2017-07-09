//
//  MovieViewController.swift
//  ororo
//
//  Created by Andrey Tsarevskiy on 08/07/2017.
//  Copyright © 2017 Andrey Tsarevskiy. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class MovieViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var countriesLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var movie: Movie? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = nameLabel.text?.appending(movie!.name)
        yearLabel.text = yearLabel.text?.appending(movie!.year)
        genreLabel.text = genreLabel.text?.appending(movie!.genres)
        descriptionLabel.text = descriptionLabel.text?.appending(movie!.desc)
        countriesLabel.text = countriesLabel.text?.appending(movie!.countries)
        ImagesHolder.updateImage(stringUrl: movie!.posterThumb, imageView: movieImage)
    
    }
    
    private func playVideo(url: URL) {
        let playerController = OroroPlayerViewController(url: url)
        self.present(playerController, animated: true)
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        OroroAPI.forOneMovie(id: movie!.id) { (movieDetailed) in
            self.playVideo(url: URL(string: movieDetailed.downloadUrl)!)
        }
    }
    

}
