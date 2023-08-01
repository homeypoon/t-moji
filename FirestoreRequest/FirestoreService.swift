//
//  FirestoreService.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation

import Foundation
import Firebase

//class FirestoreService {
//    static let shared = FirestoreService()
//    private let db = Firestore.firestore()

class FirestoreService {
    
    static let shared = FirestoreService()
    let db = Firestore.firestore()
    
    private let firestoreRequest = FirestoreRequest()
    
    func fetchDataFromFirestore(collectionName: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        firestoreRequest.getFirestoreData(collectionName: collectionName) { (data, error) in
            completion(data, error)
        }
    }
    
    func fetchDataFromFirestore(collectionName: String, documentID: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
            firestoreRequest.getFirestoreData(collectionName: collectionName, documentID: documentID) { (data, error) in
                completion(data, error)
            }
        }
    
    func writeFirestoreData(collectionName: String, documentID: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
            firestoreRequest.writeFirestoreData(collectionName: collectionName, documentID: documentID, data: data) { error in
                completion(error)
            }
        }
    
    func writeFirestoreData(collectionName: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
            firestoreRequest.writeFirestoreData(collectionName: collectionName, data: data) { error in
                completion(error)
            }
        }
}
