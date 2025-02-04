import Foundation
import FirebaseFirestore

class DataPersistenceManager {
    
    static let shared = DataPersistenceManager()
    private let db = Firestore.firestore()
    private let collectionName = "user_downloads"
    
    enum DatabaseError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    
    // Save Title to Firestore
    func downloadTitleWith(model: FirestoreTitle, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentId = "\(model.userId)_\(model.id)" // Unique identifier
        let data: [String: Any] = [
            "id": model.id,
            "userId": model.userId,
            "mediaType": model.mediaType ?? "",
            "originalName": model.originalName ?? "",
            "originalTitle": model.originalTitle ?? "",
            "posterPath": model.posterPath ?? "",
            "overview": model.overview ?? "",
            "voteCount": model.voteCount,
            "releaseDate": model.releaseDate ?? "",
            "voteAverage": model.voteAverage
        ]
        
        db.collection(collectionName).document(documentId).setData(data) { error in
            if let error = error {
                print("Failed to save to Firestore: \(error.localizedDescription)")
                completion(.failure(DatabaseError.failedToSaveData))
            } else {
                print("Data saved successfully to Firestore")
                completion(.success(()))
            }
        }
    }
    
    // Fetch Titles from Firestore
    func fetchingTitlesFromDatabase(userId: String, completion: @escaping (Result<[FirestoreTitle], Error>) -> Void) {
        db.collection(collectionName).whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(DatabaseError.failedToFetchData))
                return
            }
            
            let titles: [FirestoreTitle] = snapshot.documents.compactMap { document in
                let data = document.data()
                return FirestoreTitle(
                    id: data["id"] as? Int ?? 0,
                    userId: data["userId"] as? String ?? "",
                    mediaType: data["mediaType"] as? String,
                    originalName: data["originalName"] as? String,
                    originalTitle: data["originalTitle"] as? String,
                    posterPath: data["posterPath"] as? String,
                    overview: data["overview"] as? String,
                    voteCount: data["voteCount"] as? Int ?? 0,
                    releaseDate: data["releaseDate"] as? String,
                    voteAverage: data["voteAverage"] as? Double ?? 0.0
                )
            }
            completion(.success(titles))
        }
    }
    
    // Delete Title from Firestore
    func deleteTitleWith(model: FirestoreTitle, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentId = "\(model.userId)_\(model.id)"
        db.collection(collectionName).document(documentId).delete { error in
            if let error = error {
                print("Failed to delete from Firestore: \(error.localizedDescription)")
                completion(.failure(DatabaseError.failedToDeleteData))
            } else {
                print("Data deleted successfully from Firestore")
                completion(.success(()))
            }
        }
    }
}
