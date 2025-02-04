import UIKit
import WebKit
import FirebaseAuth

class TitlePreviewViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Download This", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let downloadedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Downloaded"
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.isHidden = true // Hidden initially
        return label
    }()
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var currentModel: TitlePreviewViewModel?
    private var isDownloaded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(downloadButton)
        view.addSubview(downloadedLabel)
        configureConstraints()
        downloadButton.addTarget(self, action: #selector(downloadTitle), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25),
            downloadButton.widthAnchor.constraint(equalToConstant: 140),
            downloadButton.heightAnchor.constraint(equalToConstant: 40),
            
            downloadedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadedLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25)
        ])
    }
    
    public func configure(with model: TitlePreviewViewModel, isDownloaded: Bool) {
        self.currentModel = model
        self.isDownloaded = isDownloaded
        
        titleLabel.text = model.title
        overviewLabel.text = model.titleOverview
        
        guard let url = URL(string: "https://www.youtube.com/embed/\(model.youtubeView.id.videoId)") else { return }
        webView.load(URLRequest(url: url))
        
        updateUIForDownloadStatus()
    }
    
    private func updateUIForDownloadStatus() {
        if isDownloaded {
            downloadButton.isHidden = true
            downloadedLabel.isHidden = false
        } else {
            downloadButton.isHidden = false
            downloadedLabel.isHidden = true
        }
    }
    
    @objc private func downloadTitle() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        guard let model = currentModel else {
            print("Model is not set")
            return
        }
        
        let firestoreTitle = FirestoreTitle(
            id: Int.random(in: 1...10000),
            userId: userId,
            mediaType: "movie",
            originalName: nil,
            originalTitle: model.title,
            posterPath: model.posterPath,
            overview: model.titleOverview,
            voteCount: 0,
            releaseDate: nil,
            voteAverage: 0.0
        )
        
        DataPersistenceManager.shared.downloadTitleWith(model: firestoreTitle) { [weak self] result in
            switch result {
            case .success:
                print("Title downloaded successfully!")
                self?.isDownloaded = true
                DispatchQueue.main.async {
                    self?.updateUIForDownloadStatus()
                }
            case .failure(let error):
                print("Failed to download title: \(error.localizedDescription)")
            }
        }
    }
}
