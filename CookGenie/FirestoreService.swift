//
//  FirestoreService.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import Foundation
import FirebaseFirestore

@Observable
final class FirestoreService {

    private let db = Firestore.firestore()
    private var historyListener: ListenerRegistration?
    private var favoritesListener: ListenerRegistration?

    var historyRecipes: [Recipe] = []
    var favoriteRecipes: [Recipe] = []
    var isLoading = false
    var error: String?
    
    // listener for all recipes ordered by creation date
    func startHistoryListener(uid: String) {
        historyListener?.remove()
        historyListener = db
            .collection("users").document(uid).collection("recipes")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.error = error.localizedDescription
                    return
                }
                self.historyRecipes = snapshot?.documents.compactMap { doc in
                    Recipe(firestoreData: doc.data())
                } ?? []
            }
    }

    // listener for recipes where isFavorite == true
    func startFavoritesListener(uid: String) {
        favoritesListener?.remove()
        favoritesListener = db
            .collection("users").document(uid).collection("recipes")
            .whereField("isFavorite", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.error = error.localizedDescription
                    return
                }
                self.favoriteRecipes = snapshot?.documents.compactMap { doc in
                    Recipe(firestoreData: doc.data())
                } ?? []
            }
    }

    func stopAllListeners() {
        historyListener?.remove()
        favoritesListener?.remove()
        historyListener = nil
        favoritesListener = nil
        historyRecipes = []
        favoriteRecipes = []
    }

    func toggleFavorite(uid: String, recipeId: String, isFavorite: Bool) {
        db.collection("users").document(uid)
            .collection("recipes").document(recipeId)
            .updateData(["isFavorite": isFavorite]) { error in
                if let error {
                    print("Error toggling favorite: \(error)")
                }
            }
    }
}
