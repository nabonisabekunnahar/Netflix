//
//  FirestoreTitle.swift
//  Netflix
//
//  Created by Sayaka Alam on 10/1/25.
//

import UIKit
import FirebaseAuth

class DownloadsViewController: UIViewController {
    
    private var titles: [FirestoreTitle] = []
    
    private let downloadedTable: UITableView = {
        let table = UITableView()
        table.register(EnhancedTitleTableViewCell.self, forCellReuseIdentifier: EnhancedTitleTableViewCell.identifier)
        table.separatorStyle = .none // Hide separators for a clean look
        table.backgroundColor = .systemBackground // Match system theme
        table.rowHeight = 180
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Downloads"
        view.addSubview(downloadedTable)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        downloadedTable.delegate = self
        downloadedTable.dataSource = self
        fetchLocalStorageForDownload()
        
        // Listen for updates when new titles are downloaded
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadDownloads),
            name: NSNotification.Name("downloaded"),
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadedTable.frame = view.bounds
    }
    
    @objc private func reloadDownloads() {
        fetchLocalStorageForDownload()
    }
    
    private func fetchLocalStorageForDownload() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        DataPersistenceManager.shared.fetchingTitlesFromDatabase(userId: userId) { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.downloadedTable.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch titles: \(error.localizedDescription)")
            }
        }
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EnhancedTitleTableViewCell.identifier,
            for: indexPath
        ) as? EnhancedTitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = titles[indexPath.row]
        
        if title.posterPath == "" {
            fetchPosterPath(for: title) { posterPath in
                DispatchQueue.main.async {
                    cell.configure(
                        with: TitleViewModel(
                            titleName: title.originalTitle ?? "Unknown Title",
                            posterURL: posterPath ?? "/defaultPoster.jpg"
                        )
                    )
                }
            }
        } else {
            cell.configure(
                with: TitleViewModel(
                    titleName: title.originalTitle ?? "Unknown Title",
                    posterURL: title.posterPath ?? "/defaultPoster.jpg"
                )
            )
        }
        
        return cell
    }
    
    private func fetchPosterPath(for title: FirestoreTitle, completion: @escaping (String?) -> Void) {
        guard let titleName = title.originalTitle ?? title.originalName else {
            completion(nil)
            return
        }
        
        APICaller.shared.search(with: titleName) { result in
            switch result {
            case .success(let titles):
                completion(titles.first?.poster_path)
            case .failure(let error):
                print("Failed to fetch poster path: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let titleToDelete = titles[indexPath.row]
            
            DataPersistenceManager.shared.deleteTitleWith(model: titleToDelete) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.titles.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                case .failure(let error):
                    print("Failed to delete title: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedTitle = titles[indexPath.row]
        guard let titleName = selectedTitle.originalTitle ?? selectedTitle.originalName else {
            return
        }

        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    vc.configure(
                        with: TitlePreviewViewModel(
                            title: titleName,
                            youtubeView: videoElement,
                            titleOverview: selectedTitle.overview ?? "No description available",
                            posterPath: selectedTitle.posterPath
                        ),
                        isDownloaded: true // Pass download status as true
                    )
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print("Failed to fetch movie: \(error.localizedDescription)")
            }
        }
    }
}
