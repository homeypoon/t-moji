//
//  FirestoreRequest.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation
import Firebase

class FirestoreRequest {
    
    private let db = Firestore.firestore()
    
    func getFirestoreData(collectionName: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        db.collection(collectionName).getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var data: [String: Any] = [:]
                for document in snapshot!.documents {
                    data[document.documentID] = document.data()
                }
                completion(data, nil)
            }
        }
    }
    
    func getFirestoreData(collectionName: String, documentID: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
            let documentRef = db.collection(collectionName).document(documentID)
            documentRef.getDocument { (document, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    if let data = document?.data() {
                        completion(data, nil)
                    } else {
                        completion(nil, nil) // Document doesn't exist or is empty
                    }
                }
            }
        }
    
    // Add or update data in Firestore
    func writeFirestoreData(collectionName: String, documentID: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        let documentRef = db.collection(collectionName).document(documentID)
        documentRef.setData(data, merge: true) { error in
            completion(error)
        }
    }
    
    func writeFirestoreData(collectionName: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
            db.collection(collectionName).addDocument(data: data) { error in
                completion(error)
            }
        }
}
