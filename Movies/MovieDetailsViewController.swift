//
//  MovieDetailsViewController.swift
//  Movies
//
//  Created by Preeten Dali on 21/11/24.
//

import UIKit
import YouTubeiOSPlayerHelper
import RealmSwift

struct MovieDetails: Decodable {
    let title: String
    let overview: String
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case posterPath = "poster_path"
    }
}

struct MovieTrailerResponse: Decodable {
    let results: [Trailer]
}

struct Trailer: Decodable {
    let key: String
    let name: String
    let type: String
}

class MovieDetailsViewController: UIViewController, YTPlayerViewDelegate {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var watchTrailerButton: UIButton!
    
    @IBAction func seatsSelectionButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showSeatsDetails", sender: nil)
    }
    
    var movieID: Int?
    private let apiKey = "b4f0fb666ea3b427ae1ac47eb7248fe4"
    private var youtubePlayerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMovieDetails()
    }
    
    private func fetchMovieDetails() {
        guard let movieID = movieID else { return }
        let realm = try! Realm()
        
        if let savedMovie = realm.object(ofType: MovieRealm.self, forPrimaryKey: movieID) {
            movieTitleLabel.text = savedMovie.title
            overviewLabel.text = savedMovie.overview
            if let posterPath = savedMovie.posterPath {
                loadPosterImage(path: posterPath)
            }
        } else {
            let urlString = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=\(apiKey)"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self = self, error == nil, let data = data else { return }
                do {
                    let movieDetails = try JSONDecoder().decode(MovieDetails.self, from: data)
                    DispatchQueue.main.async {
                        self.movieTitleLabel.text = movieDetails.title
                        self.overviewLabel.text = movieDetails.overview
                        if let posterPath = movieDetails.posterPath {
                            self.loadPosterImage(path: posterPath)
                        }
                    }
                    
                    let movieRealm = MovieRealm()
                    movieRealm.id = movieID
                    movieRealm.title = movieDetails.title
                    movieRealm.overview = movieDetails.overview
                    movieRealm.posterPath = movieDetails.posterPath
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(movieRealm, update: .modified)
                    }
                } catch {
                    print("Error decoding movie details: \(error)")
                }
            }.resume()
        }
    }
    
    private func loadPosterImage(path: String) {
        let imageUrl = "https://image.tmdb.org/t/p/w500\(path)"
        guard let url = URL(string: imageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, error == nil, let data = data else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    @IBAction func watchTrailerTapped(_ sender: UIButton) {
        fetchTrailer()
    }
    
    private func fetchTrailer() {
        guard let movieID = movieID else { return }
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/videos?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, error == nil, let data = data else { return }
            do {
                let trailerResponse = try JSONDecoder().decode(MovieTrailerResponse.self, from: data)
                if let trailer = trailerResponse.results.first(where: { $0.type == "Trailer" }) {
                    DispatchQueue.main.async {
                        self.playTrailer(videoKey: trailer.key)
                    }
                }
            } catch {
                print("Error decoding trailer response: \(error)")
            }
        }.resume()
    }
    
    private func playTrailer(videoKey: String) {
        youtubePlayerView = YTPlayerView(frame: view.bounds)
        youtubePlayerView.delegate = self
        view.addSubview(youtubePlayerView)
        youtubePlayerView.load(withVideoId: videoKey)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
}
