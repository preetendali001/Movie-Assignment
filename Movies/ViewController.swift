//
//  ViewController.swift
//  Movies
//
//  Created by Preeten Dali on 21/11/24.
//

import UIKit
import RealmSwift

struct Movie: Decodable {
    let id: Int
    let title: String
    let releaseDate: String
    let overview: String
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case overview
        case posterPath = "poster_path"
    }
}

struct MovieResponse: Decodable {
    let results: [Movie]
}

class ViewController: UIViewController {
    
    var tableView: UITableView!
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchMovies()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
        view.addSubview(tableView)
    }
    
    private func fetchMovies() {
        let realm = try! Realm()
        let savedMovies = realm.objects(MovieRealm.self)
        
        if savedMovies.isEmpty {
            let apiKey = "b4f0fb666ea3b427ae1ac47eb7248fe4"
            let urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)"
            
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("Error fetching movies: \(error)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                    self?.movies = movieResponse.results
                    
                    let realm = try! Realm()
                    try! realm.write {
                        for movie in movieResponse.results {
                            let movieRealm = MovieRealm()
                            movieRealm.id = movie.id
                            movieRealm.title = movie.title
                            movieRealm.overview = movie.overview
                            movieRealm.posterPath = movie.posterPath
                            realm.add(movieRealm, update: .modified)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }.resume()
        } else {
            self.movies = savedMovies.map { movieRealm in
                return Movie(id: movieRealm.id, title: movieRealm.title, releaseDate: "", overview: movieRealm.overview, posterPath: movieRealm.posterPath)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = movies[indexPath.row]
        cell.textLabel?.text = movie.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        print("Selected Movie: \(movie.title)") // Debugging line
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailsViewController") as? MovieDetailsViewController {
            detailsVC.movieID = movie.id
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
